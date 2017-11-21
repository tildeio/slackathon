module Slackathon
  class Command
    def self.dispatch_command(params)
      self.new(params).call
    end

    def self.dispatch_interaction(params)
      action = params[:actions][0]
      method = self.new(params).public_method(action[:name])
      value = action[:value]

      if method.arity == 0
        method.call
      else
        method.call(self.unescape(value))
      end
    end

    def self.unescape(message)
      message.gsub(/&amp;/, "&")
        .gsub(/&lt;/, "<")
        .gsub(/&gt;/, ">")
    end

    def initialize(params)
      @params = params
    end

    private

    attr_reader :params
  end
end
