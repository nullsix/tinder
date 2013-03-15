FactoryGirl.define do
  factory :draft do
    piece { FactoryGirl.build_stubbed :piece }
    number { 0 }
  end
end
