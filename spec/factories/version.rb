require 'faker'

FactoryGirl.define do
  factory :version do
    title { Faker::Lorem.words(2).join(" ") }
    content { Faker::Lorem.paragraph }
    piece { FactoryGirl.build_stubbed :piece }
  end

  factory :invalid_version, parent: :version do |f|
    f.title { nil }
  end
end
