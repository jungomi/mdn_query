module TestUtils
  class Spy
    attr_accessor :return_value

    def initialize(return_value = nil)
      @state = {
        called: false,
        count: 0,
        with_args: [],
        errors: []
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
    alias called_with? called_with_args?

    def called_at_least?(num)
      called? && @state[:count] > num
    end

    def called_at_most?(num)
      called? && @state[:count] < num
    end

    def call_count
      @state[:count]
    end
    alias count call_count

    def call_args
      @state[:with_args]
    end
    alias args call_args

    def errors
      @state[:errors]
    end

    def error_count
      @state[:errors].size
    end

    def thrown?(error, msg = nil)
      @state[:errors].include?(error: error, msg: msg)
    end
    alias thrown_error? thrown?

    def thrown_message?(msg)
      @state[:errors].each { |e| return true if e[:msg] == msg }
    end
    alias thrown_msg? thrown_message?

    def thrown_once?
      thrown_times?(1)
    end

    def thrown_times?(num)
      called? && @state[:errors].size == num
    end

    def reset
      @state = {
        called: false,
        count: 0,
        with_args: [],
        errors: []
      }
    end

    def method
      lambda do |*args|
        add_call(args)
        @return_value
      end
    end

    def throws(error, msg = nil)
      lambda do |*args|
        add_call(args, error: error, msg: msg)
        raise error, msg
      end
    end
    alias throws_error throws

    def throws_message(msg)
      lambda do |*args|
        add_call(args, error: RuntimeError, msg: msg)
        raise msg
      end
    end
    alias throws_msg throws_message

    private

    def add_call(args, error: nil, msg: nil)
      @state[:called] = true
      @state[:count] += 1
      @state[:with_args] << args
      error = RuntimeError if error.nil? && !msg.nil?
      @state[:errors] << { error: error, msg: msg } unless error.nil?
    end
  end
end
