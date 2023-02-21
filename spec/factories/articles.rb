FactoryBot.define do
  factory :article do
    title { Faker::Lorem.characters(number: 1..16) }
    body { Faker::Lorem.characters(number: 1..16) }
    user # association :user の省略形
    status { 0 }
  end
end
