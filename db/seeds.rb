# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

require "factory_bot"
require "database_cleaner"

DatabaseCleaner.strategy = :truncation
DatabaseCleaner.clean

FactoryBot.create_list :user, 10, :with_lots

Lot.all.each do |lot|
  User.where.not(id: lot.user_id).sample(5).each do |user|
    FactoryBot.create :bid, user: user, lot: lot, proposed_price: lot.current_price + 100
  end
end
