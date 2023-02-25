# == Schema Information
#
# Table name: articles
#
#  id         :bigint           not null, primary key
#  body       :text
#  status     :string           default("draft")
#  title      :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  user_id    :bigint           not null
#
# Indexes
#
#  index_articles_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
require "rails_helper"

RSpec.describe Article, type: :model do
  context "タイトルと本文があるとき" do
    it "投稿される" do
      article = build(:article)
      expect(article).to be_valid
    end
  end

  context "status が下書き状態のとき" do
    let(:draft) { build(:article, :draft) }
    it "記事を下書き状態で作成できる" do
      expect(draft).to be_valid
      expect(draft.status).to eq "draft"
    end
  end

  context "status が公開状態のとき" do
    let(:published) { build(:article, :published) }
    it "記事を公開状態で作成できる" do
      subject
      expect(published).to be_valid
      expect(published.status).to eq "published"
    end
  end
end
