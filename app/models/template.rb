class Template < ApplicationRecord
  belongs_to :templatetype
  belongs_to :year
  has_many :users
  has_many :sheets
  has_many :schedules

  def template_name
    "#{year.year}: #{templatetype.template_type}"
  end

end
