FactoryGirl.define do
  factory :piece do
    ignore do
      versions_count 5
    end

    user

    after(:create) do |piece, evaluator|
      FactoryGirl.create_list(:version, evaluator.versions_count, piece: piece)
    end
  end
end
