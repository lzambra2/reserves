# frozen_string_literal: true

class Search::PrimoController < ApplicationController
  include ApplicationHelper

  authorize_resource Request

  def create
    @query = params[:q]
    @search_type = params[:type]

    finder = BibFinder.new
    @records = finder.search_primo(@query, 10, @search_type)
  end
end
