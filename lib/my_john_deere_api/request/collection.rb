class MyJohnDeereApi::Request::Collection
  include Enumerable

  attr_reader :accessor, :associations

  ##
  # accessor is an OAuth::AccessToken object which has the necessary
  # credentials to make the desired requests.

  def initialize(accessor, associations = {})
    @accessor = accessor
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

    @first_page = JSON.parse(@accessor.get(resource, headers).body)

    @items = @first_page['values'].map{|record| model.new(record) }

    if next_page = @first_page['links'].detect{|link| link['rel'] == 'nextPage'}
      @next_page = next_page['uri'].gsub(@accessor.consumer.site, '')
    end

    @first_page
  end

  def fetch
    return unless @next_page

    page = JSON.parse(@accessor.get(@next_page, headers).body)
    @items += page['values'].map{|record| model.new(record) }

    if next_page = @first_page['links'].detect{|link| link['rel'] == 'nextPage'}
      @next_page = uri_path(next_page['uri'])
    else
      @next_page = nil
    end
  end

  def headers
    @headers ||= {accept: 'application/vnd.deere.axiom.v3+json'}
  end

  def uri_path(uri)
    uri.gsub(@accessor.consumer.site, '')
  end
end