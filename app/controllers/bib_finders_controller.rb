# frozen_string_literal: true

require 'rubygems'
require 'rsolr'

class BibFindersController < ApplicationController
  skip_authorization_check

  def search_records
    if params[:term]
      term = params[:term]
      @query_string = term.to_s

    else
      @query_string = ''

    end

    @max = params[:max_results] || 5
    @search_on = params[:on] || 'book'

    bib_record = BibFinder.new
    @bib_results = bib_record.search_items_all_sources(@query_string, @max, @search_on)

    respond_to do |format|
      format.html
      format.js
    end
  end

  def search_primo
    bib_record = BibFinder.new
    @max = params[:max_results] || 5
    @search_on = params[:on] || 'book'

    @results = bib_record.search_primo(params[:q], @max, @search_on) if params[:q]
  end
end
