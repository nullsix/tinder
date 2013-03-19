FactoryGirl.define do
  factory :draft do
    association :version
    number { 0 }

    after :create do |draft, evaluator|
      draft.version ||= FactoryGirl.create :version, draft: draft
    end
  end
end
