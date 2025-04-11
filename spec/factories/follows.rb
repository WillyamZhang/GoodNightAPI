FactoryBot.define do
  factory :follow do
    user
    association :followed, factory: :user
  end
end
