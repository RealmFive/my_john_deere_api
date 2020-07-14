module MyJohnDeereApi
  class Accessor < SimpleDelegator
    def get(*args)
      result = super(*args)

      while result['retry-after']
        sleep result['retry-after'].to_i
        result = super(*args)
      end

      result
    end

    def post(*args)
      result = super(*args)

      while result['retry-after']
        sleep result['retry-after'].to_i
        result = super(*args)
      end

      result
    end

    def put(*args)
      result = super(*args)

      while result['retry-after']
        sleep result['retry-after'].to_i
        result = super(*args)
      end

      result
    end

    def delete(*args)
      result = super(*args)

      while result['retry-after']
        sleep result['retry-after'].to_i
        result = super(*args)
      end

      result
    end
  end
end

