require 'faker'

FactoryGirl.define do
  factory :version do
    title { Faker::Lorem.words(2).join(" ") }
    content { Faker::Lorem.paragraph }

    after(:stub) do |version, evaluator|
      version.piece { FactoryGirl.build_stubbed(:piece) }
    end

    after(:build, :create) do |version, evaluator|
      version.piece { FactoryGirl.create(:piece) }
    end
  end
end
