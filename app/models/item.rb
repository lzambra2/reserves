class Item < ApplicationRecord
  # attr_accessor :title, :author, :isbn, :callnumber, :description, :publication_date, :publisher, :edition, :item_type, :copyright_options, :other_copyright_options, :format, :description, :url, :status, :provided_by_requestor, :map_index_num

  ########################################### CONSTANTS ############################################
  METADATA_MANUAL = 'MANUAL'
  METADATA_SOLR = 'SOLR'
  METADATA_WORLDCAT = 'WORLDCAT'

  ## TYPES
  TYPE_BOOK = 'book'
  TYPE_EBOOK = 'ebook'
  TYPE_MULTIMEDIA = 'multimedia'
  TYPE_COURSE_KIT = 'course_kit'
  TYPE_PHOTOCOPY = 'photocopy'
  TYPE_MAP = 'map'
  TYPE_EJOURNAL = 'ejournal'
  TYPE_PRINT_PERIODICAL = 'print_periodical'

  TYPES = [TYPE_BOOK, TYPE_EBOOK, TYPE_MULTIMEDIA, TYPE_COURSE_KIT, TYPE_PHOTOCOPY, TYPE_MAP, TYPE_EJOURNAL,
           TYPE_PRINT_PERIODICAL]

  ## FORMAT
  FORMAT_CD = 'CD'
  FORMAT_DVD = 'DVD'
  FORMAT_BOOK = 'BOOK'
  FORMAT_EBOOK = 'EBOOK'
  FORMAT_VHS = 'VHS'
  FORMAT_LP = 'LP'
  FORMAT_MAP = 'MAP'
  FORMAT_ARTICLE = 'ARTICLE'
  FORMAT_OTHER = 'OTHER'
  FORMAT_STREAMING = 'STREAMING'

  MULTIMEDIA_FORMATS = [FORMAT_CD, FORMAT_DVD, FORMAT_VHS, FORMAT_LP, FORMAT_STREAMING]

  ## COPYRIGHT OPTIONS
  COPYRIGHT_OPTIONS = defined?(Setting) ? Setting.item_copyright_options : nil

  ## STATUSES
  STATUS_READY = 'ready'
  STATUS_NOT_READY = 'not_ready'
  STATUS_DELAYED = 'delayed'
  STATUS_DELETED = 'deleted'

  #################################################### RELATIONS #########################################

  belongs_to :request, inverse_of: :items
  audited associated_with: :request

  has_many :acquisition_requests, -> { order 'acquisition_requests.status, acquisition_requests.created_at desc' }

  ################################################ VALIDATIONS #######################################

  # COMMON
  validates_presence_of :metadata_source, :request, :item_type, :loan_period, :status

  validates_length_of :title, maximum: 250, message: 'Cannot be longer than 250 characters'
  validates_length_of :author, maximum: 250, message: 'Cannot be longer than 250 characters'
  validates_length_of :publisher, maximum: 250, message: 'Cannot be longer than 250 characters'
  validates_length_of :edition, maximum: 250, message: 'Cannot be longer than 250 characters'
  validates_length_of :isbn, maximum: 250, message: 'Cannot be longer than 250 characters'
  validates_numericality_of :isbn, allow_blank: true
  validates_length_of :ils_barcode, maximum: 50, allow_blank: true, message: 'Cannot be longer than 250 numbers'
  # validates_numericality_of :ils_barcode, message: "Must be a number"

  validates_format_of :url, with: URI::DEFAULT_PARSER.make_regexp(%w[http https]), allow_blank: true,
                            message: 'URL is invalid. Please check again.'

  # BOOK
  validates_presence_of :title, :author, :isbn, :publisher, if: proc { |i| i.item_type == TYPE_BOOK }
  validates_inclusion_of :format, in: [FORMAT_BOOK, FORMAT_EBOOK], if: proc { |i| i.item_type == TYPE_BOOK }

  # EBOOK
  validates_presence_of :title, :author, :publisher, if: proc { |i| i.item_type == TYPE_EBOOK }
  validates_inclusion_of :format, in: [FORMAT_BOOK, FORMAT_EBOOK], if: proc { |i| i.item_type == TYPE_EBOOK }

  # MULTEMEDIA
  validates_presence_of :title, :author, :format, if: proc { |i| i.item_type == TYPE_MULTIMEDIA }
  validates_inclusion_of :format, in: MULTIMEDIA_FORMATS, if: proc { |i| i.item_type == TYPE_MULTIMEDIA }

  # PHOTOCOPY
  validates_presence_of :title, :author, :copyright_options, if: proc { |i| i.item_type == TYPE_PHOTOCOPY }
  validates_inclusion_of :format, in: [FORMAT_OTHER], if: proc { |i| i.item_type == TYPE_PHOTOCOPY }

  # COURSE KIT
  validates_presence_of :title, :author, if: proc { |i| i.item_type == TYPE_COURSE_KIT }
  validates_inclusion_of :format, in: [FORMAT_OTHER], if: proc { |i| i.item_type == TYPE_COURSE_KIT }

  # MAP
  validates_presence_of :title, :map_index_num, if: proc { |i| i.item_type == TYPE_MAP }
  validates_inclusion_of :format, in: [FORMAT_MAP], if: proc { |i| i.item_type == TYPE_MAP }

  # EJOURNAL
  validates_presence_of :title, :author, :publication_date, :journal_title, :volume, :page_number, if: proc { |i|
                                                                                                         i.item_type == TYPE_EJOURNAL
                                                                                                       }
  validates_inclusion_of :format, in: [FORMAT_ARTICLE], if: proc { |i| i.item_type == TYPE_EJOURNAL }

  # PRINT_PERIODICAL
  validates_presence_of :title, :author, :publication_date, :journal_title, :volume, :page_number, if: proc { |i|
                                                                                                         i.item_type == TYPE_PRINT_PERIODICAL
                                                                                                       }
  validates_inclusion_of :format, in: [FORMAT_ARTICLE], if: proc { |i| i.item_type == TYPE_PRINT_PERIODICAL }

  ## SPECIAL CASE -> require callnumber to be updated if Item is provided by requestor and status is STATUS_READY
  # validates_presence_of :callnumber, if: Proc.new { |i| i.provided_by_requestor == true && i.status == STATUS_READY }

  ##################################################### SCOPES #############################################

  ## METADATA
  scope :solr, -> { where(metadata_source: METADATA_SOLR) }
  scope :manual, -> { where(metadata_source: METADATA_MANUAL) }
  scope :worldcat, -> { where(metadata_source: METADATA_WORLDCAT) }

  ## STATUSES
  scope :ready, -> { where(status: STATUS_READY) }
  scope :not_ready, -> { where('status = ? OR status IS NULL', STATUS_NOT_READY) }
  scope :deleted, -> { where(status: STATUS_DELETED) }
  scope :delayed, -> { where(status: STATUS_DELAYED) }
  scope :active, -> { where('status <> ? ', STATUS_DELETED) }

  scope :by_type, ->(type = TYPE_BOOK) { where(item_type: type) }

  ## Ordering
  scope :recent_first, -> { order('created_at desc') }
  scope :recent_last, -> { order('created_at asc') }

  #### CONSTRUCTOR ####

  def initialize(attributes = {})
    super
    self[:status] = Item::STATUS_NOT_READY
  end

  ########################################### OVERRIDEN METHODS ####################

  def item_type
    self[:item_type].nil? ? Item::TYPE_BOOK : self[:item_type]
  end

  def status
    self[:status].nil? ? Item::STATUS_NOT_READY : self[:status]
  end

  ####### HELPER METHODS #########
  def rollover(request_id)
    ni = Item.new(attributes)

    ni.request_id = request_id # change the requester id
    ni.id = nil ## important: remove id
    ni.status = STATUS_NOT_READY
    ni.updated_at = nil
    ni.created_at = nil

    ni.save(validate: false)
    ni
  end

  def destroy
    self[:status] = STATUS_DELETED
    save(validate: false)
  end
end
