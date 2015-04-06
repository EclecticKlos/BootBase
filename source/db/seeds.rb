require 'faker'


User.create(username: "Dan")

10.times do
  User.create(username: Faker::Name.name)
end
