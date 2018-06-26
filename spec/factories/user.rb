# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    first_name { Faker::Name.first_name }
    last_name  { Faker::Name.last_name }
    sequence(:email) { |n| n.to_s + Faker::Internet.free_email }
    password "password"
    password_confirmation "password"
    phone  { Faker::PhoneNumber.cell_phone }
    birth_day { DateTime.now - rand(21..55).years }
    confirmed_at { DateTime.current }

    trait :with_lots do
      after(:create) do |user|
        create_list :lot, 2, user: user
      end
    end
  end
end
