class Templatetype < ApplicationRecord
  has_many :templates

  validates :template_type, uniqueness: { case_sensitive: false }

end
