# frozen_string_literal: true

class BibResult
  attr_accessor :title, :author, :isbn_issn, :callnumber, :publication_date, :publisher, :edition,
                :item_type, :format, :map_index_num, :journal_title, :volume, :page_number,
                :issue, :ils_barcode, :ils_id, :description, :main_location, :url, :rtype,
                :catalogue_record, :source, :language, :subject

  def self.process_primo_records(records)
    return if records.nil?

    results = []
    records.docs.each do |record|
      result = BibResult.new
      result.from_primo record
      # pp  result.get_value(record[:pnx]["display"]["title"])
      # pp result.title
      results << result
    end

    results
  end

  def self.process_solr_records(records)
    return if records.nil?

    results = []
    records.each do |record|
      results << BibResult.new.from_solr(record)
    end

    results
  end

  def from_solr(record); end

  def from_primo(record)
    self.source = 'primo'
    self.catalogue_record = record

    self.title = get_value record[:pnx]['display']['title']
    self.author = get_value record[:pnx]['sort']['author']
    self.item_type = get_value record[:pnx]['display']['type']
    self.description = get_value record[:pnx]['display']['format']
    self.edition = get_value record[:pnx]['display']['edition']
    self.publisher = get_value record[:pnx]['display']['publisher']
    self.language = begin
      get_value record[:pnx]['display']['language']
    rescue StandardError
      'n/a'
    end
    self.subject = begin
      get_value record[:pnx]['display']['subject']
    rescue StandardError
      'n/a'
    end
    self.publication_date = get_value record[:pnx]['addata']['date']
    self.callnumber = begin
      get_value record[:delivery]['holding'].first['callNumber']
    rescue StandardError
      'n/a'
    end
    self.main_location = begin
      get_value record[:delivery]['holding'].first['mainLocation']
    rescue StandardError
      'n/a'
    end
    self.isbn_issn = get_value record[:pnx]['addata']['isbn']

    ## journals
    self.isbn_issn = get_value record[:pnx]['addata']['issn'] if isbn_issn.blank?
    self.journal_title = get_value record[:pnx]['addata']['jtitle']
    self.volume = get_value record[:pnx]['addata']['volume']
    self.issue = get_value record[:pnx]['addata']['issue']
    self.page_number = "#{get_value(record[:pnx]['addata']['spage'])} #{get_value(record[:pnx]['addata']['epage'])}"
    self.url = get_value record[:pnx]['addata']['url']

    self.rtype = begin
      get_value record[:pnx]['search']['rsrctype']
    rescue StandardError
      nil
    end
  end

  def get_value(value)
    if value.nil?
      ''
    elsif value.is_a? Array
      if value.size > 1
        begin
          value.join(', ')
        rescue StandardError
          'n/a'
        end
      else
        begin
          value.try :first
        rescue StandardError
          'n/a'
        end
      end
    else
      value
    end
  end

  def to_json(*_args)
    require 'json'

    JSON.generate(
      { title: title,
        author: author,
        isbn_issn: isbn_issn,
        callnumber: callnumber,
        publication_date: publication_date,
        publisher: publisher,
        edition: edition,
        item_type: item_type,
        format: self.format,
        map_index_num: map_index_num,
        journal_title: journal_title,
        volume: volume,
        page_number: page_number,
        issue: issue,
        ils_barcode: ils_barcode,
        ils_id: ils_id,
        description: description,
        main_location: main_location,
        url: url,
        rtype: rtype }
    )
  end
end
