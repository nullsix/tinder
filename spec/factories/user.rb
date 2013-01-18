require 'faker'

FactoryGirl.define do
  factory :user do
    uid { Faker::Lorem.word }
    provider { Faker::Lorem.word }
    name { Faker::Name.name }

    ignore do
      pieces_count 5
    end

    after(:create) do |user, evaluator|
      FactoryGirl.create_list(:piece, evaluator.pieces_count, user: user)
    end
  end
end
