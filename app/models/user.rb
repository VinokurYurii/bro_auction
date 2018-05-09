class User < ApplicationRecord

  validates :email, :first_name, :last_name, :birth_day, :phone, presence: true
  validates :email, :phone, :uniqueness => { :case_sensitive => false }
  validates :phone, :numericality => true
  validate :age_must_be_greater_then_21, :email_validate

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  def age_must_be_greater_then_21
    if (birth_day - DateTime.now.to_date) / 365.25 < 21
      errors.add(:birth_day, "Age can't be less then 21 year")
    end
  end

  def email_validate
    begin
      mail = Mail::Address.new(email)
    rescue Mail::Field::ParseError
      errors.add(:email, "is not an email")
    end
  end
end
