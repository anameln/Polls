# == Schema Information
#
# Table name: responses
#
#  id               :integer          not null, primary key
#  answer_choice_id :integer
#  responder_id     :integer
#  created_at       :datetime
#  updated_at       :datetime
#

class Response < ActiveRecord::Base
  validate :respondent_has_not_already_answered_question

  belongs_to :answer_choice,
    class_name: "AnswerChoice",
    foreign_key: :answer_choice_id,
    primary_key: :id

  belongs_to :responder,
    class_name: "User",
    foreign_key: :responder_id,
    primary_key: :id

  has_one :question, through: :answer_choice, source: :question
  #returns instance of Question

  def sibling_response
    #question.responses.where.not(id: self.id)
    #question.responses.where(self.id.nil? ? "responses.id != ?" : "responses.id IS NOT NULL", self.id)
    Response.find_by_sql([<<-SQL, self.answer_choice_id, self.id])
      SELECT
        responses.*
      FROM
        responses
      JOIN
        answer_choices
      ON
        responses.answer_choice_id = answer_choices.id
      JOIN
        questions
      ON
        answer_choices.question_id = questions.id
      WHERE
        answer_choices.id = ? AND
        responses.id != ? AND
        responses.id IS NOT NULL
    SQL
  end

  private

  def respondent_has_not_already_answered_question
    ids = []
    sibling_response.each do |sib|
      ids << sib.id
    end

    if Response.exists?(responder_id: ids)
      errors[:responder] << "has already answered question"
    end
  end
end
