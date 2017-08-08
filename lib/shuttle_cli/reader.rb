require 'pp'
module ShuttleCli
  class Reader
    attr_accessor :bookmarks

    def initialize(key)
      @key = key.downcase if key
      self.bookmarks = load_bookmarks(key)
      self
    end

    def load_bookmarks(key)
      json = bookmarks_json.with_indifferent_access
      hosts = json[:hosts].flatten
      converted = hosts.select do |h|
        if @key
          h.keys.first.downcase.include? @key
        else 
          true
        end
      end.map do |h|
        Bookmark.new_from_json h
      end
      # For now flatten all.
      converted.map do |b|
        if b.children
          b.children
        else
          b
        end
      end.flatten
    end

    def json_location
      open(ENV['HOME']+'/.shuttle.json')
    end

    def json_file_content
      File.open(json_location, "rb") {|f| f.read }
    end

    def bookmarks_json
      JSON.parse json_file_content
    end
  end
end
