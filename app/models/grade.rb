class Grade < ApplicationRecord
  has_many :users
  has_many :next_levels, class_name: "Grade",
                          foreign_key: "grade_id"

  belongs_to :grade, optional: true
end
