require "rails_helper"

RSpec.describe User, type: :model do
  context "nameが入力されているとき" do
    it "ユーザーが作成される" do
      # user = User.new(name: "taro", email: "abc@test.com", password: "pass123")
      user = build(:user)
      expect(user).to be_valid
    end
  end

  context "nameが入力されていないとき" do
    it "ユーザーが作成できない" do
      # user = User.new(name: "", email: "abc@test.com", password: "pass123")
      user = build(:user, name: nil)
      expect(user).to be_invalid
      # expect(user.errors.details[:name][0][:error]).to eq :blank
    end
  end

  # context "nameがユニークなとき" do
  #   it "ユーザーが作成される" do
  #     user = User.new(name: "taro", email: "abc@test.com", password: "pass123")
  #     expect(user).to be_valid
  #   end
  # end

  context "nameがユニークでないとき" do
    it "ユーザー作成できない" do
      # User.create!(name: "taro", email: "abc@test.com", password: "pass123")
      # user = User.new(name: "taro", email: "def@test.com", password: "pass456")
      create(:user, name: "namae")
      user = build(:user, name: "namae")
      expect(user).to be_invalid
      # expect(user.errors.details[:name][0][:error]).to eq :taken
    end
  end

  context "emailが入力されていないとき" do
    it "ユーザー作成できない" do
      user = build(:user, email: nil)
      expect(user).to be_invalid
      # expect(user.errors.details[:email][0][:error]).to eq :blank
    end
  end

  context "passwordが入力されていないとき" do
    it "ユーザー作成できない" do
      user = build(:user, password: nil)
      expect(user).to be_invalid
      # expect(user.errors.details[:password][0][:error]).to eq :blank
    end
  end
end
