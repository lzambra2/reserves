class AcquisitionRequest < ApplicationRecord
  ##### DB Fields for reference (update if changes)
  # "id", "item_id", "requested_by_id", "acquisition_reason", "status", "list_id", "location_id",
  # "cancelled_by_id", "cancellation_reason", "cancelled_at", "acquired_by_id", "acquired_at",
  # "acquisition_notes", "acquisition_source_type", "acquisition_source_name", "created_at", "updated_at"
  #####

  ## Audited
  audited

  ## CONSTANTS
  STATUS_OPEN = 'open'
  STATUS_ACQUIRED = 'acquired'
  STATUS_CANCELLED = 'cancelled'
  STATUSES = [STATUS_ACQUIRED, STATUS_CANCELLED]

  EMAIL_TO_BOOKSTORE = 'bookstore'
  EMAIL_TO_ACQUISITIONS = 'acquisitions_department'
  EMAIL_TO_LOCATION = 'locations_acquisition_email'

  ## RELATIONS
  belongs_to :item
  belongs_to :location
  belongs_to :request
  belongs_to :requested_by, class_name: 'User', foreign_key: 'requested_by_id'
  belongs_to :acquired_by, class_name: 'User', foreign_key: 'acquired_by_id'
  belongs_to :cancelled_by, class_name: 'User', foreign_key: 'cancelled_by_id'

  ## VALIDATIONS
  validates_presence_of :item, :requested_by, :location ## default basic validation
  validates_presence_of :acquired_by, :acquired_at, :acquisition_source_type, :acquisition_source_name, if: lambda {
                                                                                                              status == STATUS_ACQUIRED
                                                                                                            }
  validates_presence_of :cancelled_by, :cancelled_at, :cancellation_reason, if: lambda {
                                                                                  status == STATUS_CANCELLED
                                                                                }

  ## SCOPES

  scope :open, -> { where(status: nil) }
  scope :acquired, -> { where(status: STATUS_ACQUIRED) }
  scope :cancelled, -> { where(status: STATUS_CANCELLED) }
  scope :by_source_type, ->(source) { where('acquisition_source_type = ? ', source) }
  scope :by_location, ->(location_id) { where('location_id = ?', location_id) }

  ## Helper Methods
  def status
    if self[:status].nil?
      STATUS_OPEN
    else
      self[:status]
    end
  end

  def email_to(whom, user)
    case whom
    when EMAIL_TO_BOOKSTORE
      AcquisitionsMailer.send_acquisition_request(self, user, Setting.email_acquisitions_to_bookstore).deliver_later
    when EMAIL_TO_ACQUISITIONS
      AcquisitionsMailer.send_acquisition_request(self, user, Setting.email_acquisitions_to).deliver_later
    else
      # EMAIL_TO_LOCATION
      AcquisitionsMailer.send_acquisition_request(self, user, location.acquisitions_email).deliver_later
    end
  end
end
