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
FactoryBot.define do
  factory :article do
    title { Faker::Lorem.characters(number: 1..16) }
    body { Faker::Lorem.characters(number: 1..16) }
    user # association :user の省略形

    trait :draft do
      status { :draft }
    end

    trait :published do
      status { :published }
    end
  end
end
