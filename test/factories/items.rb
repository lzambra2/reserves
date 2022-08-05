# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :item do
    association :request, factory: :request

    metadata_source Item::METADATA_MANUAL
    status Item::STATUS_NOT_READY
    loan_period '2 Hours'

    title 'WOOT'
    author 'John McCain'
    isbn '97811222'
    callnumber 'AB 1010 AB78'
    description 'Woot Book'
    publication_date '2014'
    publisher 'Random House'
    item_type Item::TYPE_BOOK
    edition '1st ed.'
    format Item::FORMAT_BOOK
    map_index_num nil
    url nil
    copyright_options nil
    other_copyright_options nil

    ils_barcode ''

    issue nil
    journal_title nil
    volume nil
    page_number nil

    provided_by_requestor false
  end
end
