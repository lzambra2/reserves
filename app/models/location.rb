class Location < ApplicationRecord
  # SETTING: setting_bcc_request_status_change

  # SERIALIZATION
  serialize :disallowed_item_types, Array

  # RELATIONSHIPS
  has_many :requests

  ## VALIDATIONS
  validates_presence_of :name, :contact_phone, :address, :contact_email, message: 'Cannot be empty'
  validates_format_of :contact_email, with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i,
                                      message: 'Invalid email format.'
  validates_format_of :acquisitions_email, with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i, allow_blank: true

  ## AUDITS
  audited

  ## SCOPES
  scope :active, -> { where(is_deleted: false) }
  scope :inactive, -> { where(is_deleted: true) }
end
