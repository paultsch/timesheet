class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable,
         :recoverable, :rememberable, :validatable
  belongs_to :grade, optional: true
  belongs_to :usertype, optional: true

  has_many :students, class_name: "User",
                          foreign_key: "supervisor_id"

  belongs_to :supervisor, class_name: "User", optional: true

  belongs_to :template, optional: true
  has_many :sheets

  def full_name
    "#{first_name} #{last_name }"
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

end
