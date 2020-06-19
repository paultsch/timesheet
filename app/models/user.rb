class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
after_update :create_schedules_in_sheets


  devise :database_authenticatable,
         :recoverable, :rememberable, :validatable
  belongs_to :grade, optional: true
  belongs_to :usertype, optional: true

  has_many :students, class_name: "User",
                          foreign_key: "supervisor_id"

  belongs_to :supervisor, class_name: "User", optional: true

  belongs_to :template, optional: true
  has_many :sheets

  validates :first_name, :last_name, presence: true

  def full_name
    "#{first_name} #{last_name }"
  end


  def self.first_name_search(param)
    search_for('first_name', param)
  end

  def self.last_name_search(param)
    search_for('last_name', param)
  end

  def self.search_for(field_name, param)
    where("#{field_name} like ?", "%#{param}%")
  end
  #
  def self.full_search(param)
    param.strip!
    to_send_back = (full_name_search(param)).uniq
    return nil unless to_send_back
    to_send_back
  end

  def self.full_name_search(search)
    @names = search.split(" ")
    where("first_name LIKE ? AND last_name LIKE ?", "%#{@names[0]}%","%#{@names[1]}%" )
  end

  def self.import(file)
    CSV.foreach(file.path, headers: true) do |row|

      user = User.find_or_initialize_email(email)
      user.update_attributes(row.to_hast)
      #User.create row.to_hash
    end
  end

  def self.to_csv
    attributes = %w{id email first_name last_name}

    CSV.generate(headers: true) do |csv|
      csv << attributes

      all.each do |user|
        csv << user.attributes.values_at(*attributes)
      end
    end
  end

  def count_missing_dates
    @template = Template.joins(:year).merge(Year.where(:current_year => true))
    active_sheets = Sheet.where(template_id: @template)
    @sheets = active_sheets.where(user_id: self.id)
    @sheet_dates = @sheets.distinct.pluck(:date)
    sign_ins = @sheets.where("date <= ?", Date.yesterday())
    @total_missed = sign_ins.where(signed_in: false).count
    return @total_missed
  end

  def count_students
    User.where(supervisor_id: self.id).count
  end


  def create_schedules_in_sheets
    @schedules = Schedule.where(template_id: self.template_id)
    @sheets = Sheet.where(user_id: self.id)
    @sheet_dates = @sheets.distinct.pluck(:date)
    @schedule_dates = @schedules.distinct.pluck(:date)
    if @sheets.count > 0
      @sheets.each do |sheet|
        if (@schedule_dates.exclude?(sheet.date) && sheet.template.year.current_year == true)
          @sheets.where(date: sheet.date).delete_all
        end
      end
    end
    @schedules.each do |schedule|
      if @sheet_dates.include?(schedule.date)
        sheet = @sheets.where(date: schedule.date)
        sheet.update(template_id: self.template_id)
      else
        Sheet.create(user_id: self.id, template_id: schedule.template_id, date: schedule.date, signed_in: false)
      end
    end
  end

private

def set_active_templates
  @template = Template.joins(:year).merge(Year.where(:current_year => true))
end


end
