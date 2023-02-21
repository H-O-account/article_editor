require "rails_helper"

RSpec.describe "Api::V1::Auth::Sessions", type: :request do
  describe "POST /api/v1/auth/sign_in" do
    subject { post(api_v1_user_session_path, params: params) }

    context "ログイン情報が適切な場合" do
      let(:user) { create(:user) }
      let(:params) { { email: user.email, password: user.password } }
      it "ログインできる" do
        subject
        header = response.header
        expect(response).to have_http_status(:ok)
        expect(header["access-token"]).to be_present
        expect(header["client"]).to be_present
        expect(header["expiry"]).to be_present
        expect(header["uid"]).to be_present
        expect(header["token-type"]).to be_present
      end
    end

    context "登録されていないメールアドレスの場合" do
      let!(:user) { create(:user) }
      let(:params) { attributes_for(:user, email: "miss@miss.com", password: user.password) }
      it "ログインできない" do
        subject
        res = JSON.parse(response.body)
        expect(res["errors"]).to include "Invalid login credentials. Please try again."
      end
    end

    context "パスワードが間違っている場合" do
      let!(:user) { create(:user) }
      let(:params) { attributes_for(:user, email: user.email, password: "misspassword") }
      it "ログインできない" do
        subject
        res = JSON.parse(response.body)
        expect(res["errors"]).to include "Invalid login credentials. Please try again."
      end
    end
  end

  describe "DELETE /api/v1/auth/sign_out" do
    subject { delete(destroy_api_v1_user_session_path, headers: headers) }

    context "ログアウトに必要な情報を送信したとき" do
      let(:user) { create(:user) }
      let(:headers) { user.create_new_auth_token }

      before { headers }

      it "ログアウトできる" do
        expect { subject }.to change { user.reload.tokens }.from(be_present).to(be_blank)
        expect(response).to have_http_status(:ok)
      end
    end

    context "誤った情報を送信したとき" do
      let(:user) { create(:user) }
      let(:headers) { { "access-token" => "", "token-type" => "", "client" => "", "expiry" => "", "uid" => "" } }

      before { headers }

      it "ログアウトできない" do
        subject
        expect(response).to have_http_status(:not_found)
        res = JSON.parse(response.body)
        expect(res["errors"]).to include "User was not found or was not logged in."
      end
    end
  end
end
