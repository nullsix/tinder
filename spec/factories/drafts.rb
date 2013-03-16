FactoryGirl.define do
  factory :draft do
    piece { FactoryGirl.build_stubbed :piece }
    version { FactoryGirl.build_stubbed :version }
    number { 0 }
  end
end
