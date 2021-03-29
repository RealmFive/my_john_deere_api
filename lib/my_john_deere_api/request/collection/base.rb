module MyJohnDeereApi
  class Request::Collection::Base
    include Enumerable
    include Helpers::UriHelpers

    attr_reader :client, :associations

    ##
    # client is the original client instance which contains
    # the necessary config info.

    def initialize(client, associations = {})
      @client = client
      @associations = associations
      @items = []
    end

    ##
    # Iterate lazily through all records in the collection, fetching
    # additional pages as needed.

    def each(&block)
      count.times do |index|
        fetch if @items.size <= index
        block.call(@items[index])
      end
    end

    ##
    # Return all objects in the collection at once

    def all
      return @all if defined?(@all)
      @all = map { |i| i }
    end

    ##
    # Total count of records, even before pagination

    def count
      @count ||= first_page['total']
    end

    private

    def first_page
      return @first_page if defined?(@first_page)

      @first_page = client.get(resource)
      extract_page_contents(@first_page)

      @first_page
    end

    def fetch
      return unless @next_page

      page = client.get(@next_page)
      extract_page_contents(page)
    end

    def extract_page_contents(page)
      add_items_from_page(page)
      set_next_page(page)
    end

    def add_items_from_page(page)
      @items += page['values'].map{|record| model.new(client, record) }
    end

    def set_next_page(page)
      if next_page = page['links'].detect{|link| link['rel'] == 'nextPage'}
        @next_page = uri_path(next_page['uri'])
      else
        @next_page = nil
      end
    end
  end
end