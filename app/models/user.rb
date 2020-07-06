class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
after_update :create_schedules_in_sheets

  devise :database_authenticatable,
         :recoverable, :rememberable
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
  def self.full_search(search)
    find_by_sql "SELECT u.id, u.first_name || ' ' || u.last_name as fullname FROM users u WHERE fullname LIKE '%#{search}%'"
  end

  def self.full_name_search(search)
    param.strip!
    to_send_back = User.select("first_name || ' ' || last_name as FullName").where("FullName LIKE ?", "%#{param}%")
    return nil unless to_send_back
    to_send_back
  end

  def self.to_csv(fields = column_names, options = {})

    CSV.generate(options) do |csv|
      csv << fields
      all.each do |user|
        csv << user.attributes.values_at(*fields)
      end
    end
  end

  def self.import(file)
    CSV.foreach(file.path, headers: true) do |row|
      user_hash = row.to_hash
      user = find_or_create_by!(email: user_hash['email'], first_name: user_hash['first_name'], last_name: user_hash['last_name'], :encrypted_password => user_hash['password'], usertype_id: 1, grade_id: 1)
      user.update_attributes(user_hash)
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
