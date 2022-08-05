class User < ApplicationRecord
  ## searchable Concern
  include Searchable

  ## CONSTANTS
  FACULTY = 'FACULTY'
  GRADUATE = 'GRADUATE'
  UNDERGRAD = 'UNDERGRAD'
  STAFF = 'STAFF'
  UNKNOWN = 'unknown'
  TYPES = [FACULTY, GRADUATE, UNDERGRAD, STAFF]

  MANAGER_ROLE = 'manager'
  SUPERVISOR_ROLE = 'supervisor'
  STAFF_ROLE = 'staff'
  INSTRUCTOR_ROLE = 'instructor'
  STUDENT_ROLE = 'student'
  STAFF_ROLES = [MANAGER_ROLE, SUPERVISOR_ROLE, STAFF_ROLE]
  USER_ROLES = [INSTRUCTOR_ROLE, STUDENT_ROLE]

  ## RELATIONSHIPS
  has_many :requests, foreign_key: 'requester_id', class_name: 'Request'
  belongs_to :created_by, foreign_key: 'created_by_id', class_name: 'User'
  belongs_to :location

  ## VALIDATIONS
  validates_presence_of :name, :email, :uid, :user_type, :role
  validates_presence_of :department, :phone, :office, unless: proc { |u| u.admin? }
  validates_presence_of :location, if: proc { |u| u.admin? }
  validates :email, presence: true, uniqueness: true, format: { with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i }

  validates_uniqueness_of :uid

  ## SCOPES
  scope :admin, -> { where(admin: true) }
  scope :users, -> { where(admin: false) }

  scope :inactive, -> { where(active: false) }
  scope :active, -> { where(active: true) }

  ## AUDITS
  audited associated_with: :location
  has_associated_audits

  def update_external(user_id)
    update_external_alma(user_id) if Setting.alma_apikey.length > 10
  end

  def update_external_alma(user_id)
    user = Alma::User.find(user_id)

    begin
      self.name = "#{user.first_name} #{user.last_name}"
      self.email = user.preferred_email
      self.phone = begin
        user['contact_info']['phone'].first['phone_number']
      rescue StandardError
        nil
      end

      office_address = nil
      user['contact_info']['address'].each do |a|
        next unless a['preferred'].to_s == 'true'

        office_address = begin
          a['line1']
        rescue StandardError
          nil
        end
      end

      self.office = if office_address.nil?
                      begin
                        user['contact_info']['address'].first['line1'].strip
                      rescue StandardError
                        nil
                      end
                    else
                      office_address
                    end

      self.library_uid = begin
        user['primary_id']
      rescue StandardError
        nil
      end
      self.user_type = begin
        user.user_group['value']
      rescue StandardError
        nil
      end

      true
    rescue Exception => e
      pp e
      logger.debug 'Failed to parse User Profile Response from source ALMA'
      false
    end
  end

  def update_external_sirsi(user_id)
    require 'json'
    require 'open-uri'
    source = "https://www.library.yorku.ca/find/Feeds/MyProfile?alt_id=#{user_id}"

    begin
      data = JSON.parse(open(source).read)

      self.name = data['firstname'].strip + ' ' + data['lastname'].strip
      self.email = begin
        data['email'].strip
      rescue StandardError
        nil
      end
      self.phone = begin
        data['phone'].strip
      rescue StandardError
        nil
      end
      self.office = begin
        data['address2'].strip
      rescue StandardError
        nil
      end
      self.library_uid = data['id']
      self.user_type = begin
        data['profile'].strip
      rescue StandardError
        nil
      end

      true
    rescue StandardError
      logger.debug "Failed to parse User Profile Response from source #{source}"

      false
    end
  end

  def inactive?
    active == false
  end
end
