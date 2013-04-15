require 'faker'

FactoryGirl.define do
  factory :version do
    title { Faker::Lorem.words(2).join(" ") }
    content { Faker::Lorem.paragraph }
    piece { FactoryGirl.build_stubbed :piece }
    number { 1 }
  end

  factory :invalid_version, parent: :version do |f|
    f.title { "a"*300 }
  end
end
