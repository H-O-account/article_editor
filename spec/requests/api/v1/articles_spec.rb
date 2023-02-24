require "rails_helper"

RSpec.describe "Api::V1::Articles", type: :request do
  describe "GET /index" do
    subject { get(api_v1_articles_path) }

    let!(:create1) { create(:article, :published, updated_at: 1.days.ago) }
    let!(:create2) { create(:article, :draft) }
    let!(:create3) { create(:article, :published, updated_at: 2.days.ago) }

    before { create2 }

    context "記事のレコードが発行された場合" do
      it "公開済みの記事の一覧が取得できる(更新順)" do
        subject
        res = JSON.parse(response.body)

        expect(response).to have_http_status(:ok)
        expect(res.length).to eq 2
        expect(res[0].keys).to eq ["id", "title", "updated_at", "user"]
        expect(res.map {|n| n["id"] }).to eq [create1.id, create3.id]
        expect(res[0]["user"].keys).to eq ["id", "name", "email"]
      end
    end
  end

  describe "GET /show" do
    subject { get(api_v1_article_path(article_id)) }

    let(:article_id) { article.id }
    context "選択した記事が公開状態であるとき" do
      let(:article) { create(:article, :published) }
      it "記事詳細が表示される" do
        subject
        res = JSON.parse(response.body)

        expect(response).to have_http_status(:ok)
        expect(res["id"]).to eq article.id
        expect(res["title"]).to eq article.title
        expect(res["body"]).to eq article.body
        expect(res["updated_at"]).to be_present
        expect(res["user"]["id"]).to eq article.user.id
        expect(res["user"].keys).to eq ["id", "name", "email"]
      end
    end

    context "選択した記事のidがないとき" do
      let(:article_id) { 1_000_000 }
      it "記事詳細が表示されない" do
        expect { subject }.to raise_error ActiveRecord::RecordNotFound
      end
    end

    context "対象の記事が下書き状態であるとき" do
      let(:article) { create(:article, :draft) }

      it "記事が見つからない" do
        expect { subject }.to raise_error ActiveRecord::RecordNotFound
      end
    end
  end

  describe "POST /create" do
    subject { post(api_v1_articles_path, params: params, headers: headers) }

    let(:current_user) { create(:user) }
    let(:headers) { current_user.create_new_auth_token }

    context "公開指定で記事を作成するとき" do
      let(:params) { { article: attributes_for(:article, :published) } }

      it "記事のレコードが作成できる" do
        expect { subject }.to change { Article.where(user_id: current_user.id).count }.by(1)
        res = JSON.parse(response.body)
        expect(res["title"]).to eq params[:article][:title]
        expect(res["body"]).to eq params[:article][:body]
        expect(response).to have_http_status(:ok)
      end
    end

    context "下書き指定で記事を作成するとき" do
      let(:params) { { article: attributes_for(:article, :draft) } }

      it "下書き記事が作成できる" do
        expect { subject }.to change { Article.count }.by(1)
        res = JSON.parse(response.body)
        expect(res["status"]).to eq "draft"
        expect(response).to have_http_status(:ok)
      end
    end
  end

  describe "PATCH /api/v1/articles/:id" do
    subject { patch(api_v1_article_path(article.id), params: params, headers: headers) }

    let(:params) { { article: attributes_for(:article, :published) } }
    let(:current_user) { create(:user) }
    let(:headers) { current_user.create_new_auth_token }

    context "自分の記事を更新するとき" do
      let!(:article) { create(:article, :draft, user: current_user) }

      it "任意の記事の更新ができる" do
        expect { subject }.to change { article.reload.title }.from(article.title).to(params[:article][:title]) &
                              change { article.reload.body }.from(article.body).to(params[:article][:body]) &
                              change { article.reload.status }.from(article.status).to(params[:article][:status].to_s)
        expect(response).to have_http_status(:ok)
      end
    end

    context "他のユーザーの記事を更新しようとるすとき" do
      let(:other_user) { create(:user) }
      let(:article) { create(:article, user: other_user) }

      before { article }

      it "更新できない" do
        expect { subject }.to raise_error(ActiveRecord::RecordNotFound)
        change { Article.count }.by(0)
      end
    end
  end

  describe "DELETE /api/v1/articles/:id" do
    subject { delete(api_v1_article_path(article_id), headers: headers) }

    let(:current_user) { create(:user) }
    let(:article_id) { article.id }
    let(:headers) { current_user.create_new_auth_token }

    context "自分の記事を削除しようとするとき" do
      let(:article) { create(:article, user: current_user) }

      before { article }

      it "記事を削除できる" do
        expect { subject }.to change { Article.count }.by(-1)
        expect(response).to have_http_status(:no_content)
      end
    end

    context "他人が所持している記事のレコードを削除しようとするとき" do
      let(:other_user) { create(:user) }
      let(:article) { create(:article, user: other_user) }

      before { article }

      it "記事を削除できない" do
        expect { subject }.to raise_error(ActiveRecord::RecordNotFound) &
                              change { Article.count }.by(0)
      end
    end
  end
end
