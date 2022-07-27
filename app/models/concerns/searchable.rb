module Searchable
  extend ActiveSupport::Concern

  if defined?(Setting) && Setting.search_elastic_enabled.to_s == 'true'
    included do
      ## INCLUSIONS
      include Elasticsearch::Model
      include Elasticsearch::Model::Callbacks

      # index_name
      index_name "#{Setting.search_elastic_index_prefix}_#{name.tableize}"

      __elasticsearch__.client = Elasticsearch::Client.new host: Setting.search_elastic_server
    end
  end
end
