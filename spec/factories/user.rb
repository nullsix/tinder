require 'faker'

FactoryGirl.define do
  factory :user do
    name { Faker::Name.name }
    provider { Faker::Lorem.word }
    uid { Faker::Lorem.word }

    ignore do
      pieces_count 1
    end

    before :stub do |user, evaluator|
      FactoryGirl.stub_list :piece, evaluator.pieces_count, user: user
    end

    before :create do |user, evaluator|
      FactoryGirl.create_list :piece, evaluator.pieces_count, user: user
    end
  end
end
