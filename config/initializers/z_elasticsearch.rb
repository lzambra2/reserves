if Setting.search_elastic_enabled.to_s == "true"
  Request.__elasticsearch__.client = Elasticsearch::Client.new host: Setting.search_elastic_server
  User.__elasticsearch__.client = Elasticsearch::Client.new host: Setting.search_elastic_server
end
