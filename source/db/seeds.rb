require 'faker'


User.create(name: "Dan")

10.times do
  User.create(name: Faker::Name.name)
end
