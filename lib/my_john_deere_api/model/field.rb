class MyJohnDeereApi::Model::Field
  attr_reader :name, :id, :links

  def initialize(record)
    @name = record['name']
    @id = record['id']
    @archived = record['archived']

    @links = {}

    record['links'].each do |association|
      @links[association['rel']] = uri_path(association['uri'])
    end
  end

  def archived?
    @archived
  end

  private

  def uri_path(uri)
    URI.parse(uri).path.gsub('/platform', '')
  end
end