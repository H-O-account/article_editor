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
