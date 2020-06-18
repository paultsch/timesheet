class Sheet < ApplicationRecord
  belongs_to :user
  belongs_to :template

  #sheet has

  def self.count_missing_dates
    Sheet.where("user_id = ? AND template_id = ? AND date <= ? AND signed_in = ?", self.id, @templates, Date.yesterday(), false).count
  end
end
