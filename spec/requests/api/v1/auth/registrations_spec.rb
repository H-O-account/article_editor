require "rails_helper"

RSpec.describe "Api::V1::Auth::Registrations", type: :request do
  describe "POST /api/v1/auth" do
    subject { post(api_v1_user_registration_path, params: params) }

    context "名前・メールアドレス・パスワードが入力されている場合" do
      let(:params) { attributes_for(:user) }
      it "ユーザー登録される" do
        expect { subject }.to change { User.count }.by(1)
        expect(response).to have_http_status(:ok)
      end

      it "header 情報を取得することができる" do
        subject
        header = response.header
        expect(header["access-token"]).to be_present
        expect(header["client"]).to be_present
        expect(header["expiry"]).to be_present
        expect(header["uid"]).to be_present
        expect(header["token-type"]).to be_present
      end
    end

    context "名前が未入力の場合" do
      let(:params) { attributes_for(:user, name: nil) }
      it "ユーザー登録されない" do
        expect { subject }.to change { User.count }.by(0)
        res = JSON.parse(response.body)
        expect(res["errors"]["full_messages"]).to include "Name can't be blank"
      end
    end

    context "メールアドレスが未入力の場合" do
      let(:params) { attributes_for(:user, email: nil) }
      it "ユーザー登録されない" do
        expect { subject }.to change { User.count }.by(0)
        res = JSON.parse(response.body)
        expect(res["errors"]["full_messages"]).to include "Email can't be blank"
      end
    end

    context "パスワードが未入力の場合" do
      let(:params) { attributes_for(:user, password: nil) }
      it "ユーザー登録されない" do
        expect { subject }.to change { User.count }.by(0)
        res = JSON.parse(response.body)
        expect(res["errors"]["full_messages"]).to include "Password can't be blank"
      end
    end
  end
end
