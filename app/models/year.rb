class Year < ApplicationRecord
  has_many :templates
  has_many :sheets, through: :templates

  validates :year, uniqueness: { case_sensitive: false }
end
