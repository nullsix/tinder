require 'faker'

FactoryGirl.define do
  factory :version do
    title { Faker::Lorem.words.join(" ") }
    content { Faker::Lorem.paragraphs.join }

    # factory :piece do
    #   id { rand 100 }
    # end
  end
end
