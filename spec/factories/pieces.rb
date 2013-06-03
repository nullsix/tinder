FactoryGirl.define do
  factory :piece do
    ignore do
      versions_count 1
    end
    
    user { FactoryGirl.build_stubbed :user }

    before :stub do |piece, evaluator|
      if !evaluator.versions_count.zero?
        FactoryGirl.stub_list :version, evaluator.versions_count, piece: piece
      end
    end

    after :create do |piece, evaluator|
      if evaluator.versions_count.zero?
        piece.versions.delete_all
      else
        FactoryGirl.create_list :version,
          evaluator.versions_count-1, piece: piece
      end
    end

    before :build do |piece, evaluator|
      FactoryGirl.build_list :version, evaluator.versions_count, piece: piece
    end

  end
end
