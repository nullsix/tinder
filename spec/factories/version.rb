require 'faker'

FactoryGirl.define do
  factory :version do
    title { Faker::Lorem.words.join(" ") }
    content { Faker::Lorem.paragraphs.join }

    piece
  end
end
