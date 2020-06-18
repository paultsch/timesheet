class AddNextGradeToGrades < ActiveRecord::Migration[6.0]
  def change
    add_reference :grades, :next_grade
  end
end
