require 'faker'
User.create(username: "Dan")

10.times do
  user = User.create(username: Faker::Name.name)
  3.times do
    project = user.projects.create(
      title:              Faker::Lorem.sentence,
      description:        Faker::Lorem.paragraph,
      user_project_code:  Faker::Lorem.paragraph(4),
      )
    2.times do
      tag = project.tags.create(
        name:             Faker::Lorem.word,
        relevance_vote:   (1 + rand(7)),
        )
    end
  end
end
