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

end
