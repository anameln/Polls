# == Schema Information
#
# Table name: users
#
#  id         :integer          not null, primary key
#  user_name  :string(255)
#  created_at :datetime
#  updated_at :datetime
#

class User < ActiveRecord::Base
  has_many :authored_polls,
    class_name: "Poll",
    foreign_key: :author_id,
    primary_key: :id

  has_many :responses,
    class_name: "Response",
    foreign_key: :responder_id,
    primary_key: :id

  def completed_polls
    # answer_choice_counts = {}
    #
    # answer_choices_with_counts = self
    #   .answer_choices
    #   .select("answer_choices.*, COUNT(responses.id) AS response_count")
    #   .joins("LEFT OUTER JOIN responses ON responses.answer_choice_id = answer_choices.id")
    #   .group("answer_choices.id")
    #
    # answer_choices_with_counts.each do |row|
    #   answer_choice_counts[row] = row.response_count
    # end
    #
    # answer_choice_counts



    SELECT
      polls.*, COUNT(polls.question_id)
    FROM
      polls
    RIGHT OUTER JOIN
      questions
    ON
      questions.poll_id = poll.id
    JOIN
      answer_choices
    ON
      answer_choices.question_id = questions.id
    JOIN (
      SELECT
        *
      FROM
        responses
      WHERE
        responder_id = self.id
      )
    ON
      responses.answer_choice_id = answer_choice.id
    WHERE
      self.id = responses.responder_id
    GROUP BY
      polls.id
    HAVING

  end
end
