class Guesses
  include Enumerable

  ITEM_MAX = 10

  def initialize
    @items = []
  end

  def each(&block)
    ITEM_MAX.times do |index|
      fetch if @items.size <= index
      block.call(@items[index])
    end
  end

  # allow comparisons for methods like sort and max
  def <=>(a,b)
    a <=> b
  end

  private

  # retrieve up to three more items
  def fetch
    puts "fetching..."

    # fetch up to three at a time, to simulate pagination.
    3.times do
      return if @items.size >= ITEM_MAX

      print "number: "; $stdout.flush
      @items << gets.chomp.to_i
    end
  end
end