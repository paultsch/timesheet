class Year < ApplicationRecord
  has_many :templates
  has_many :sheets, through: :templates
end
