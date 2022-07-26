require "rubygems"
require 'rsolr'

class BibFindersController < ApplicationController

  skip_authorization_check

  def search_records


    if params[:term]
      term = params[:term]
      @query_string = "#{term}"

    else
      @query_string = ""

    end

    params[:max_results] ? @max = params[:max_results] : @max = 5
    params[:on] ? @search_on = params[:on] : @search_on = "book"

    bib_record = BibFinder.new()
    @bib_results = bib_record.search_items_all_sources(@query_string, @max, @search_on)

    respond_to do |format|
        format.html
        format.js
    end

  end

  def search_primo
    bib_record = BibFinder.new()
    params[:max_results] ? @max = params[:max_results] : @max = 5
    params[:on] ? @search_on = params[:on] : @search_on = "book"

    if params[:q]
      @results = bib_record.search_primo(params[:q], @max, @search_on)
    end
  end


end
