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
end
