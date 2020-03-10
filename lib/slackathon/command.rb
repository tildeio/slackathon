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

    def say(body)
      Slackathon.say(params[:response_url], body)
    end

    # Slack limits responses per URL to 5, so we recommend
    # not calling this more than 4 times per command
    def report_progress(data = {})
      @progress_count ||= 0

      if (@progress_count += 1) > 4
        warn("do not call Slackathon::Command#report_progress more than 4 times")
        return
      end

      say(
        response_type: :ephemeral,
        text: format(progress_message, data)
      )
    end

    def progress_message
      "Running command (%<percent>d percent complete)"
    end

    # this immediate empty response should prevent slack
    # from thinking there has been a timeout.
    #
    # If you expect `call` to take more than 3000ms to return
    # a response, we recommend you call `ack_receipt` at the
    # top of the `call` method.
    def ack_receipt
      Net::HTTP.get(URI(params[:response_url]))
    end
  end
end
