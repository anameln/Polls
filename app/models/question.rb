# == Schema Information
#
# Table name: questions
#
#  id         :integer          not null, primary key
#  text       :text
#  poll_id    :integer
#  created_at :datetime
#  updated_at :datetime
#

class Question < ActiveRecord::Base
  belongs_to :poll,
    class_name: "Poll",
    foreign_key: :poll_id,
    primary_key: :id

  has_many :answer_choices,
    class_name: "AnswerChoice",
    foreign_key: :question_id,
    primary_key: :id

  has_many :responses, through: :answer_choices, source: :responses
  #returns instances of Response


  def results_n_plus_one
    answer_choices = self.answer_choices
    answer_choice_counts = {}

    answer_choices.each do |choice|
      answer_choice_counts[choice] = choice.responses.length
    end

    answer_choice_counts
  end

  def results
    answer_choices = self.answer_choices.includes(:responses)
    answer_choice_counts = {}

    answer_choices.each do |choice|
      answer_choice_counts[choice] = choice.responses.length
    end

    answer_choice_counts
  end

  def results_double_query
    answer_choice_counts = {}

    answer_choices_with_counts = self
      .answer_choices
      .select("answer_choices.*, COUNT(responses.id) AS response_count")
      .joins("LEFT OUTER JOIN responses ON responses.answer_choice_id = answer_choices.id")
      .group("answer_choices.id")

    answer_choices_with_counts.each do |row|
      answer_choice_counts[row] = row.response_count
    end

    answer_choice_counts
  end

  def results_by_sql
    AnswerChoice.find_by_sql([<<-SQL, self.id])
      SELECT
        answer_choices.*, COUNT(responses.id) AS response_count
      FROM
        responses
      JOIN
        answer_choices
      ON
        responses.answer_choice_id = answer_choices.id
      WHERE
        answer_choices.question_id = ?
      GROUP BY
        answer_choices.id
    SQL
  end


end
