class User < ActiveRecord::Base
  attr_accessor :password, :role, :old_password, :new_password, :confirm_password

  has_and_belongs_to_many :privileges

  validates_uniqueness_of :username, :email
  validates_length_of     :username, :within => 1..20
  validates_length_of     :password, :within => 4..40, :on => :create
  validates_format_of     :username,
    :with => /^[A-Z0-9_]*$/i,
    :message => "must contain only letters, numbers, and underscores"
  validates_format_of     :email,
    :with => /^[A-Z0-9._%-]+@([A-Z0-9-]+\.)+[A-Z]{2,4}$/i,
    :message => "must be a valid email address"
  validates_presence_of :email

  def before_save
    self.salt = random_string(8) if self.salt == nil
    self.hashed_password = Digest::SHA1.hexdigest(self.salt + self.password) unless self.password.nil?

    self.admin    = false
    self.student  = false
    #self.employee = false

    self.admin    = true if self.role == 'Admin'
    self.student  = true if self.role == 'Student'
    #self.employee = true if self.role == 'Employee'
  end

  def self.authenticate?(username, password)
    u = User.find_by_username username
    u.hashed_password == Digest::SHA1.hexdigest(u.salt + password)
  end

  def random_string(len)
    randstr = ""
    chars = ("0".."9").to_a + ("a".."z").to_a + ("A".."Z").to_a
    len.times { randstr << chars[rand(chars.size - 1)] }
    randstr
  end

  def role_name
    return "Admin" if self.admin?
    return "Student" if self.student?
   # return "Employee" if self.employee?
    return nil
  end
  


  def role_symbols
    prv = []
    privileges.map do |privilege|
      prv << privilege.name.underscore.to_sym
    end
   
    if admin?
      return [:admin]+ prv
    elsif student?
      return [:student] + prv
    elsif employee?
      return [:employee] + prv
    else
      return prv
    end
  end
  
  
end
