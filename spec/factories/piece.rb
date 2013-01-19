FactoryGirl.define do
  factory :piece do
    ignore do
      versions_count 1
    end
    
    user { build_stubbed(:user) }

    before(:stub) do |piece, evaluator|
      FactoryGirl.stub_list(:version, evaluator.versions_count, piece: piece)
    end

    before(:build, :create) do |piece, evaluator|
      FactoryGirl.create_list(:version, evaluator.versions_count, piece: piece)
    end
  end
end
