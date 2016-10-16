module TestUtils
  class Spy
    attr_accessor :return_value

    def initialize(return_value = nil)
      @state = {
        called: false,
        count: 0,
        with_args: []
      }
      @return_value = return_value
    end

    def called?
      @state[:called]
    end

    def called_once?
      called_times?(1)
    end

    def called_times?(num)
      called? && @state[:count] == num
    end

    def called_with_args?(*args)
      called? && @state[:with_args].include?(args)
    end

    def called_at_least?(num)
      called? && @state[:count] > num
    end

    def called_at_most?(num)
      called? && @state[:count] < num
    end

    def call_count
      @state[:count]
    end

    def call_args
      @state[:with_args]
    end

    def reset
      @state = {
        called: false,
        count: 0,
        with_args: []
      }
    end

    def method
      lambda do |*args|
        add_call(args)
        @return_value
      end
    end

    private

    def add_call(args)
      @state[:called] = true
      @state[:count] += 1
      @state[:with_args] << args
    end
  end
end
