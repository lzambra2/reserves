# frozen_string_literal: true

require 'ostruct'

class BibFinder
  ## CONSTANTS
  SOLR = 'SOLR'
  VUFIND = 'VUFIND'
  WORLDCAT = 'WORLDCAT'

  def search_primo(search_string, max_number_of_results = 20, type = 'book')
    @query = Primo::Search::Query.new(value: search_string)
    add_primo_facets(type)

    records = Primo.find(q: @query, limit: max_number_of_results)
    BibResult.process_primo_records records
  end

  def add_primo_facets(type)
    resource_types = %w[books articles maps media dissertations images reviews]

    case type
    when 'book'
      @query.facet({ field: 'rtype', value: 'books' })
    when 'ebook'
      @query.facet({ field: 'rtype', value: 'books' })
      @query.facet({ field: 'tlevel', value: 'online_resources' })
    when 'multimedia'
      @query.facet({ field: 'rtype', value: 'media' })
    when 'map'
      @query.facet({ field: 'rtype', value: 'maps' })
    when 'ejournal'
      @query.facet({ field: 'rtype', value: 'journals' })
      @query.facet({ field: 'tlevel', value: 'online_resources' })
    when 'print_periodical'
      @query.facet({ field: 'rtype', value: 'journals' })
    end
  end

  def search_items_all_sources(search_string, max_number_of_results = 6, search_on = 'book')
    # Only search if enabled, use worldcat as back for either
    records = []

    vufind_results = search_vufind_for_results(search_string, max_number_of_results, search_on)
    records = sanitise_records(vufind_results, SOLR)
    records = records.first(max_number_of_results.to_i) # work around for now to the limititaion of VUfind RSS implementation

    if records&.size&.zero? && Setting.worldcat_enable == 'true'
      worldcat_results = search_worldcat_for_results(search_string, max_number_of_results)
      records = sanitise_records(worldcat_results, WORLDCAT)
    end

    records
  end

  def search_vufind_for_results(query = '*:*', _number_of_records = 6, on = 'book')
    filter_query = case on
                   when 'book'
                     'BookTitle'
                   when 'ebook'
                     'EBookTitle'
                   when 'multimedia'
                     'MultimediaTitle'
                   when 'map'
                     'MapTitle'
                   when 'ejournal'
                     'EJournalTitle'
                   when 'print_periodical'
                     'PrintPeriodicalTitle'
                   else
                     'BookTitle'
                   end

    # filter_query_expanded = "filter[]=" + filter_query.join("&filter[]=")
    # url = "#{Setting.vufind_url}?json=true&view=rss&lookfor=#{URI.encode(query.squish)}&#{URI.encode(filter_query_expanded.squish)}"

    url = "#{Setting.vufind_url}?json=true&view=rss&lookfor=#{URI.encode(query.squish)}&type=#{URI.encode(filter_query.squish)}"
    results = JSON.parse(open(url))
  end

  def search_solr_for_results(query = '*:*', number_of_records = 5, on = 'book')
    require 'rsolr'

    query = '*:*' if query.blank? || query == '' || query.empty?

    title_author_qf = 'title_short_txtP^757.5   title_short^750  title_full_unstemmed^404   title_full^400   title_txtP^750   title^500   title_alt_txtP_mv^202   title_alt^200   title_new_txtP_mv^101   title_new^100 author^100 author_fuller^50 author2 author_additional'

    ## vufind search yaml has fulltext instead of the last two isbn issn at the end. This qf taken from Papyrus Project.
    vufind_qf = 'title_short_txtP^757.5   title_short^750  title_full_unstemmed^404   title_full^400   title_txtP^750   title^500   title_alt_txtP_mv^202   title_alt^200   title_new_txtP_mv^101   title_new^100   series^50   series2^30   author^500   author_fuller^150   contents^10   topic_unstemmed^404   topic^400   geographic^300   genre^300   allfields_unstemmed^10   fulltext_unstemmed^10   allfields isbn issn'

    solr = RSolr.connect url: Setting.solr_url

    case on
    when 'book'
      query_fields = title_author_qf
      filter_query = ['source_str:Catalogue', 'format:("Book")']

    when 'ebook'
      query_fields = title_author_qf
      filter_query = ['source_str:Catalogue', 'format:("eBook") OR format:("eReserves")']

    when 'multimedia'
      query_fields = title_author_qf
      filter_query = ['source_str:Catalogue', 'format:("Audio Compact Disc" OR "Audio Cassette" OR "Audio LP" OR "Audio Reel" OR "Audio 78 RPM"
         OR "CD-ROM" OR "DVD" OR "Streaming Audio" OR "Streaming Video" OR "Film" OR "Laserdisc"
         OR "Score" OR "Digitized Score" OR "E-Score" OR "Video" OR "Multimedia" OR "Sound Recording" OR "Music Recording"
         OR "Data File" OR "Encyclopedia/Dictionary" OR "Slide" OR "Computer File"
        )']

    when 'map'
      query_fields = title_author_qf
      filter_query = ['source_str:Catalogue', 'format:("map" OR "eMap" OR "Image")']

    # Note from Ali: Feature of limiting to eJournals postpond for later update
    when 'ejournal'
      query_fields = title_author_qf
      filter_query = ['source_str:Catalogue', 'format:("eJournal") OR format:("eReserves")']

    else
      query_fields = vufind_qf
      filter_query = ['source_str:Catalogue']
    end

    result = solr.get 'select', params: {
      q: query.to_s,
      defType: 'dismax',
      # :bf => "recip(ms(NOW,publishDateBoost_tdate),3.16e-11,1,1)^1.0",
      pf: 'title_txtP^100',
      qf: query_fields,
      start: 0,
      rows: number_of_records,
      fq: filter_query
    }

    if (result['response']['numFound']).positive?
      result['response']['docs']
      # return result
    else
      []
    end
  end

  def search_worldcat_for_results(query, number_of_records = 5)
    require 'worldcatapi'

    worldcat_key = Setting.worldcat_key
    num = number_of_records.to_s

    client = WORLDCATAPI::Client.new(key: worldcat_key, debug: false)
    response = client.SRUSearch(query: "\"#{query}\"", maximumRecords: num)
    # response = client.OpenSearch(q: query, format: 'atom', start: 1, count: 5, cformat: "all")

    if response.records.size.positive?
      response.records
    else
      []
    end
  end

  # Take results from source and compose a new array
  def sanitise_records(results, source)
    return if results.nil?

    sanitised_array = []

    case source
    when SOLR

      results.each do |r|
        # r.inspect
        # puts r
        res = OpenStruct.new
        res.source = VUFIND
        res.id = r['id']
        res.title = r['title_full']

        author = array_or_string(r, 'author')
        author2 = array_or_string(r, 'author2')
        res.author = if author.blank?
                       author2
                     else
                       author
                     end

        res.format = array_or_string(r, 'format')
        res.callnumber = array_or_string(r, 'callnumber')
        res.isbn = r['isbn']
        res.issn = r['issn']
        res.publisher = array_or_string(r, 'publisher')
        res.publish_date = array_or_string(r, 'publishDate')
        res.edition = array_or_string(r, 'edition')
        res.description = array_or_string(r, 'description')
        res.physical_description = array_or_string(r, 'physical')
        res.url = array_or_string(r, 'url')
        sanitised_array << res
      end

      sanitised_array

    when WORLDCAT

      results.each do |wc|
        # wc.inspect

        res = OpenStruct.new
        res.source = WORLDCAT.titleize
        res.id = wc.id
        res.title = wc.title
        res.author = wc.author
        res.isbn = wc.isbn # if array, its being taken care of in view of bib_results
        res.publisher = wc.publisher
        res.publish_date = wc.publishDate
        res.edition = wc.edition
        res.description = wc.summary
        res.physical_description = wc.physical_description
        # res.url = wc.url # Worldcat does not have URL
        sanitised_array << res
      end

      sanitised_array
    end
  end

  def array_or_string(result, field_name)
    return '' unless result[field_name]

    if result[field_name].is_a? Array
      result[field_name].join(', ')
    else
      result[field_name]
    end
  end
end
