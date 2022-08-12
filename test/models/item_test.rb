# frozen_string_literal: true

require 'test_helper'

class ItemTest < ActiveSupport::TestCase
  should 'create a valid item' do
    item = build(:item)

    assert_difference 'Item.count', 1 do
      item.save
    end
  end

  ################### VALIDATION TESTS

  should 'not create an invalid item, common requirements' do
    # assert ! build(:item, department: nil).valid?, "Department should be present"
    assert !build(:item, request: nil).valid?, 'Request should be present'
    assert !build(:item, metadata_source: nil).valid?, 'Metadata Source should be present'
    # not needed since we overriding to make sure its never nil ----> assert ! build(:item, item_type: nil).valid?, "Item Type should be present"
    assert !build(:item, loan_period: nil).valid?, 'Loan Period is a required'
    # status will always return not_ready if it's nil ----> assert ! build(:item, status: nil).valid?, "Status should be set"
  end

  should 'not create an invalid BOOK or EBOOK item' do
    # BOOK
    assert !build(:item, title: nil, item_type: Item::TYPE_BOOK).valid?, 'Title is required for book'
    assert !build(:item, author: nil, item_type: Item::TYPE_BOOK).valid?, 'Author is required for book'
    assert !build(:item, isbn: nil, item_type: Item::TYPE_BOOK).valid?, 'ISBN is required for book'
    assert !build(:item, publisher: nil, item_type: Item::TYPE_BOOK).valid?, 'Publisher is required for book'

    assert !build(:item, format: 'anos', item_type: Item::TYPE_BOOK).valid?, 'Format must be book'
    assert build(:item, format: Item::FORMAT_BOOK, item_type: Item::TYPE_BOOK).valid?, 'Should be valid'

    # EBOOK
    assert !build(:item, title: nil, item_type: Item::TYPE_EBOOK).valid?, 'Title is required for ebook'
    assert !build(:item, author: nil, item_type: Item::TYPE_EBOOK).valid?, 'Author is required for ebook'
    # assert ! build(:item, isbn: nil, item_type: Item::TYPE_EBOOK).valid?, "ISBN is required for ebook"
    assert !build(:item, publisher: nil, item_type: Item::TYPE_EBOOK).valid?, 'Publisher is required for ebook'

    assert !build(:item, format: 'anos', item_type: Item::TYPE_EBOOK).valid?, 'Format must be book'
    assert build(:item, format: Item::FORMAT_EBOOK, item_type: Item::TYPE_EBOOK).valid?, 'Should be valid'
  end

  should 'not create an invalid eJournal Item' do
    # EJournal
    assert !build(:item, title: nil, item_type: Item::TYPE_EJOURNAL).valid?, 'Title is required for ejournal'
    assert !build(:item, author: nil, item_type: Item::TYPE_EJOURNAL).valid?, 'Author is required for ejournal'
    assert !build(:item, publication_date: nil, item_type: Item::TYPE_EJOURNAL).valid?,
           'Publication Date is required for ejournal'
    assert !build(:item, journal_title: nil, item_type: Item::TYPE_EJOURNAL).valid?,
           'Journal Title is required for ejournal'
    assert !build(:item, volume: nil, item_type: Item::TYPE_EJOURNAL).valid?, 'Volume is required for ejournal'
    assert !build(:item, page_number: nil, item_type: Item::TYPE_EJOURNAL).valid?,
           'Page Number is required for ejournal'
  end

  should 'not create an invalid print_periodical Item' do
    # print_periodical
    assert !build(:item, title: nil, item_type: Item::TYPE_PRINT_PERIODICAL).valid?,
           'Title is required for print_periodical'
    assert !build(:item, author: nil, item_type: Item::TYPE_PRINT_PERIODICAL).valid?,
           'Author is required for print_periodical'
    assert !build(:item, publication_date: nil, item_type: Item::TYPE_PRINT_PERIODICAL).valid?,
           'Publication Date is required for print_periodical'
    assert !build(:item, journal_title: nil, item_type: Item::TYPE_PRINT_PERIODICAL).valid?,
           'Journal Title is required for print_periodical'
    assert !build(:item, volume: nil, item_type: Item::TYPE_PRINT_PERIODICAL).valid?,
           'Volume is required for print_periodical'
    assert !build(:item, page_number: nil, item_type: Item::TYPE_PRINT_PERIODICAL).valid?,
           'Page Number is required for print_periodical'
  end

  should 'not create an invalid MULTIMEDIA Item' do
    assert !build(:item, title: nil, item_type: Item::TYPE_MULTIMEDIA).valid?, 'Title is required for multimedia'
    assert !build(:item, author: nil, item_type: Item::TYPE_MULTIMEDIA).valid?, 'Author is required for multimedia'
    assert !build(:item, format: nil, item_type: Item::TYPE_MULTIMEDIA).valid?, 'Format is required for multimedia'

    assert !build(:item, format: 'something', item_type: Item::TYPE_MULTIMEDIA).valid?,
           "Format must be one of #{Item::MULTIMEDIA_FORMATS}"
  end

  should 'not create an invalid MAP or Course Kit or Photocopy item' do
    assert !build(:item, title: nil, item_type: Item::TYPE_MAP).valid?, 'Title is required for map'
    assert !build(:item, callnumber: nil, item_type: Item::TYPE_MAP).valid?, 'Callnumber is required for map'
    assert !build(:item, format: 'something', item_type: Item::TYPE_MAP).valid?, 'Format must be MAP'

    assert !build(:item, title: nil, item_type: Item::TYPE_COURSE_KIT).valid?, 'Title is required for course kit'
    assert !build(:item, author: nil, item_type: Item::TYPE_COURSE_KIT).valid?, 'Author is required for course kit'
    assert !build(:item, format: 'something', item_type: Item::TYPE_COURSE_KIT).valid?, 'Format must be OTHER'

    assert !build(:item, title: nil, item_type: Item::TYPE_PHOTOCOPY).valid?, 'Title is required for photocopy'
    assert !build(:item, author: nil, item_type: Item::TYPE_PHOTOCOPY).valid?, 'Author is required for photocopy'
    assert !build(:item, copyright_options: nil, item_type: Item::TYPE_PHOTOCOPY).valid?,
           'Copyright options are required for photocopy'
    assert !build(:item, format: 'something', item_type: Item::TYPE_PHOTOCOPY).valid?, 'Format must be OTHER'
  end

  should 'Ensure callnumber is present if status is READY and item is provided by requestor' do
    # assert ! build(:item, callnumber: nil, provided_by_requestor: true, status: Item::STATUS_READY).valid?, "Should not be valid"
    assert build(:item, callnumber: 'woot', provided_by_requestor: true, status: Item::STATUS_READY).valid?,
           'Should be valid'

    assert build(:item, callnumber: nil, provided_by_requestor: true, status: Item::STATUS_NOT_READY).valid?,
           'Should still be valid'
  end

  should 'update the status' do
    item = create(:item, status: Item::STATUS_NOT_READY)
    item.status = Item::STATUS_READY
    item.save
    assert_equal Item::STATUS_READY, item.status
  end

  should 'not create item with invalid length' do
    longer_than_250 = 'A' * 251

    assert !build(:item, title: longer_than_250).valid?, 'Item Title cannot be larger than 250 characters'
    assert !build(:item, author: longer_than_250).valid?, 'Item Author cannot be larger than 250 characters'
    assert !build(:item, publisher: longer_than_250).valid?, 'Item Publisher cannot be larger than 250 characters'
    assert !build(:item, edition: longer_than_250).valid?, 'Item Edition cannot be larger than 250 characters'
    assert !build(:item, isbn: longer_than_250).valid?, 'Item ISBN cannot be larger than 250 characters'
  end

  context 'URL Validation' do
    should 'invalid URL with URI' do
      # /^(http|https):\/\/[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(([0-9]{1,5})?\/.*)?$/ix
      # Above regx does not do port numbers but does catch that "http://" to be invalid while
      # URI:regexp will pass it.

      my_url = 'https://www.google.com:8080'
      result = my_url =~ URI::DEFAULT_PARSER.make_regexp(%w[http https])
      assert_equal result, 0, message: 'URL of myurl is not valid'
    end

    should allow_value('https://www.google.com:8080').for(:url)
    should_not allow_value('www.google.com:8080').for(:url)
  end
  ################# SCOPE TESTS

  should 'list items based on metadatasource' do
    create_list(:item, 1, metadata_source: Item::METADATA_MANUAL)
    create_list(:item, 2, metadata_source: Item::METADATA_SOLR)
    create_list(:item, 3, metadata_source: Item::METADATA_WORLDCAT)

    assert_equal 1, Item.manual.size
    assert_equal 2, Item.solr.size
    assert_equal 3, Item.worldcat.size
  end

  should 'list items based on status' do
    create_list(:item, 1, status: Item::STATUS_READY)
    create_list(:item, 2, status: Item::STATUS_NOT_READY)
    create_list(:item, 3, status: Item::STATUS_DELAYED)
    create_list(:item, 4, status: Item::STATUS_DELETED)

    assert_equal 1, Item.ready.size
    assert_equal 2, Item.not_ready.size
    assert_equal 3, Item.delayed.size
    assert_equal 4, Item.deleted.size

    assert_equal 6, Item.active.size
  end

  ############### METHOD TESTS

  should 'return default item type as BOOK if item type is nil' do
    item = Item.new
    item.item_type = nil

    assert_not_nil item.item_type, 'Should not be nil'
    assert_equal Item::TYPE_BOOK, item.item_type, 'should be book if nil'

    item.item_type = Item::TYPE_MAP
    assert_equal Item::TYPE_MAP, item.item_type, 'SHould be map'
  end

  should 'rollover an item, by making an exact copy and removing the id and timestmaps' do
    i = create(:item, status: Item::STATUS_READY)

    item = i.rollover(200)
    assert_not_equal item.request_id, i.request_id
    assert_not_equal item.created_at, i.created_at
    assert_not_equal item.updated_at, i.updated_at
    assert_equal item.request_id, 200
    assert_equal Item::STATUS_NOT_READY, item.status, 'Status should be set to not ready'

    item.attributes.except(:request_id, :id, :created_at, :updated_at, :status).each do |attribute|
      assert item[attribute] == i[attribute], "Attribute #{attribute} should match"
    end
  end

  should 'set item status to STATUS_DELETED on calling destroy method' do
    i = create(:item, status: Item::STATUS_READY)

    i.destroy
    assert_equal Item::STATUS_DELETED, i.status
  end
end
