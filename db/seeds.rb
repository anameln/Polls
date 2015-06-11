# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

names = ['Tom', 'John', 'Katrina', 'Ari', 'Ralph', 'Toby', 'Sylvia', 'Jebadaiah', 'Christie', 'Lucy']
polls = ['Countries', 'Coding Languages', 'Animals', 'Colors']
questions = ['Which is best?', 'Which is worst?', "Which doesn't matter?", "How red is your blood?"]
answer_choices = ['A', 'B,' 'C', 'D', 'E']

names.each do |n|
  u = User.create!(user_name: n)
  po = Poll.create!(title: polls.sample, author_id: u.id)
  Question.create!(text: questions.sample, poll_id: po.id)
end

Question.pluck(:id).each do |q_id|
  answer_choices.each do |choice|
    AnswerChoice.create!(text: choice, question_id: q_id)
  end
end

30.times do
  user = User.pluck(:id).sample
  a_choice = AnswerChoice.pluck(:id).sample
  Response.create!(answer_choice_id: a_choice, responder_id: user)
end
