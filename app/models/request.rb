# frozen_string_literal: true

class Request < ApplicationRecord
  ## searchable Concern
  include Searchable

  ## CONSTANTS
  INCOMPLETE = 'incomplete'
  OPEN = 'open'
  INPROGRESS = 'in progress'
  COMPLETED = 'completed'
  CANCELLED = 'cancelled'
  REMOVED = 'removed'
  UPCYCLED = 'upcycled'
  STATUSES = [OPEN, INPROGRESS, COMPLETED, CANCELLED].freeze

  OPEN_STATUSES = [INCOMPLETE, OPEN].freeze
  VISIBLE_STATUSES = [OPEN, INPROGRESS, COMPLETED, UPCYCLED].freeze
  CLOSED_STATUSES = [INPROGRESS, COMPLETED, CANCELLED, REMOVED, UPCYCLED].freeze

  ## RELATIONS
  has_many :items, inverse_of: :request

  belongs_to :course
  belongs_to :reserve_location, class_name: 'Location', foreign_key: 'reserve_location_id'

  belongs_to :requester, foreign_key: 'requester_id', class_name: 'User'
  belongs_to :assigned_to, foreign_key: 'assigned_to_id', class_name: 'User'
  belongs_to :archiver, foreign_key: 'removed_by_id', class_name: 'User'

  belongs_to :rollover_parent, foreign_key: 'rollover_parent_id', class_name: 'Request'
  has_many :rollovers, foreign_key: 'rollover_parent_id', class_name: 'Request'

  # audited only: [:status, :assigned_to]

  # audited #:comment_required => true
  audited associated_with: :course
  has_associated_audits

  ## VALIDATIONS

  # :requester_id, :course_id, :item_id ,:assigned_to_id, :department_id,
  validates_presence_of :reserve_start_date, :reserve_location_id, :course, :reserve_end_date,
                        message: 'Cannot be empty'
  validates_presence_of :requester_id, message: 'Must set a requester'
  validates :requester_email, format: { with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i, allow_blank: true }

  # NESTING
  accepts_nested_attributes_for :items, allow_destroy: true
  accepts_nested_attributes_for :course, allow_destroy: true
  accepts_nested_attributes_for :requester, allow_destroy: false

  ## SCOPES
  scope :incomplete, -> { where(status: INCOMPLETE) }
  scope :open, -> { where(status: OPEN) }
  scope :in_progress, -> { where(status: INPROGRESS) }
  scope :completed, -> { where(status: COMPLETED) }
  scope :cancelled, -> { where(status: CANCELLED) }
  scope :removed, -> { where(status: REMOVED) }
  scope :upcycled, -> { where(status: UPCYCLED) }
  scope :visible, -> { where('status IN (?)', VISIBLE_STATUSES) }
  scope :expiring_soon, lambda { |expire_date = (Time.now + Setting.request_expiry_notice_interval.to_i)|
                          where('requests.reserve_end_date <= ? ', expire_date).where(status: COMPLETED)
                        }

  scope :rollovers, -> { where.not(rollover_parent_id: nil) }

  def location
    reserve_location
  end

  ####### HELPER METHODS #########
  def rolledover?
    rollover_parent != nil
  end

  ### Rollover Method makes a new request and copies required data from this one, including items
  def rollover(course_year = '', course_term = '', course_section = '', course_credits = '')
    ## copy request

    nr = Request.new
    nr.requester_id = self[:requester_id]
    nr.reserve_location_id = self[:reserve_location_id]
    nr.requester_email = self[:requester_email]

    nr.requested_date = DateTime.now.beginning_of_day
    nr.course_id = nil
    nr.status = OPEN
    nr.rollover_parent_id = self[:id]
    nr.rolledover_at = DateTime.now
    nr.audit_comment = 'Rolledover request'

    nr.save(validate: false)

    ## rollover items
    items.active.each do |i|
      i.rollover(nr.id)
    end

    ## rollover course
    course = self.course.rollover(course_year, course_term, course_section, course_credits)

    nr.update(course_id: course.id)

    # change it's status to UPCYCLED
    self.audit_comment = "Rolling over request and settings this request to #{UPCYCLED} status"
    update(status: UPCYCLED)

    nr
  end

  def self.mass_archive(user_id = 0, archive = true)
    expire_date = Date.today - (Setting.request_archive_all_after.to_i / 60 / 60 / 24).days
    requests = Request.completed.where('requests.reserve_end_date <= ? ', expire_date)

    requests.each do |request|
      request.status = Request::REMOVED
      request.removed_at = Date.today
      request.removed_by_id = user_id
      request.save(validate: false) if archive
    end

    requests
  end

  def self.remove_incomplete(remove = false)
    expire_date = Date.today - (Setting.request_remove_incomplete_after.to_i / 60 / 60 / 24).days
    requests = Request.incomplete.where('created_at <= ?', expire_date)

    requests.each do |request|
      request.destroy! if remove
    end

    requests
  end

  ### ELASRTIC SEARCH HELPERS ##
  def short_course_code
    !course.nil? ? "#{course.subject} #{course.course_id}" : ''
  end

  def instructor_name
    !course.nil? ? course.instructor.to_s : ''
  end

  def as_indexed_json(_options = {})
    as_json(
      only: [:id],
      include: %i[course reserve_location assigned_to items requester],
      methods: %i[short_course_code instructor_name]
    )
  end
end
