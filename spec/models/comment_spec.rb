require "rails_helper"

RSpec.describe Comment, type: :model do
  context "コメントがあるとき" do
    it "投稿される" do
      comment = build(:comment)
      expect(comment).to be_valid
    end
  end
end
