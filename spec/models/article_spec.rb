require "rails_helper"

RSpec.describe Article, type: :model do
  context "タイトルと本文があるとき" do
    it "投稿される" do
      article = build(:article)
      expect(article).to be_valid
    end
  end

  context "下書きとして保存する場合" do
    let(:draft) { build(:article, status: 0) }
    it "statusの値が0になる" do
      expect(draft).to be_valid
      expect(draft.status).to eq "draft"
    end
  end

  context "公開して保存する場合" do
    let(:published) { build(:article, status: 1) }
    it "statusの値が1になる" do
      subject
      expect(published).to be_valid
      expect(published.status).to eq "published"
    end
  end
end
