require "rails_helper"

RSpec.describe "Api::V1::Articles", type: :request do
  describe "GET /index" do
    subject { get(api_v1_articles_path) }

    context "記事のレコードが発行された場合" do
      let!(:create1) { create(:article, updated_at: 1.days.ago) }
      let!(:create2) { create(:article) }
      let!(:create3) { create(:article, updated_at: 2.days.ago) }

      it "記事の一覧が取得できる" do
        subject
        res = JSON.parse(response.body)

        expect(response).to have_http_status(:ok) # 接続可能か
        expect(res.length).to eq 3 # resの配列に作成した記事が３つあるか
        expect(res[0].keys).to eq ["id", "title", "updated_at", "user"] # キーが合っているか
        expect(res.map {|n| n["id"] }).to eq [create2.id, create1.id, create3.id] # 記事が更新日付順で出力されているか
        expect(res[0]["user"].keys).to eq ["id", "name", "email"] # 記事に対するユーザー情報が作成されているか
      end
    end
  end

  describe "GET /show" do
    subject { get(api_v1_article_path(article_id)) }

    context "選択した記事のidがあるとき" do
      let(:article) { create(:article) }
      let(:article_id) { article.id }
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
  end

  describe "POST /create" do
    subject { post(api_v1_articles_path, params: params) }

    # stub
    before { allow_any_instance_of(Api::V1::BaseApiController).to receive(:current_user).and_return(current_user) } # rubocop:disable RSpec/AnyInstance

    context "ログインしているユーザーが投稿したとき" do
      let(:params) { { article: attributes_for(:article) } }
      let(:current_user) { create(:user) }
      it "記事が作成される" do
        expect { subject }.to change { Article.where(user_id: current_user.id).count }.by(1) # ログインユーザーの記事のレコードが増えているか
        res = JSON.parse(response.body)
        expect(res["title"]).to eq params[:article][:title] # 記事のタイトルが同じか
        expect(res["body"]).to eq params[:article][:body] # 記事のボディが同じか
        expect(response).to have_http_status(:ok)
      end
    end
  end
end
