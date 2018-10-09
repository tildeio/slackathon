require "net/http"
require "uri"

module Slackathon
  class SlackCommandJob < ApplicationJob
    queue_as Slackathon.queue

    def perform(name, type, params)
      klass = name.constantize
      params = params.with_indifferent_access
      url = params[:response_url]

      body = case type
      when "command"
        klass.dispatch_command(params)
      when "interaction"
        klass.dispatch_interaction(params)
      end

      say(url, body)
    rescue => e
      if Slackathon.report_errors?
        say(url, {
          response_type: "ephemeral",
          text: <<~TEXT
            :mac_bomb: Darn - that slash command (#{name.underscore.gsub("_command", "")}) didn't work
            ```
            #{e.class}: #{e.message}
            #{e.backtrace.take(5).map { |line| line.indent(4) }.join("\n")}
                ...
            ```
          TEXT
        })
      end

      raise e if Slackathon.raise_errors?
    end

    private

    def say(url, body)
      uri = URI(url)
      headers = { "Content-Type" => "application/json" }
      body = (String === body) ? body : body.to_json
      response = Net::HTTP.post uri, body, headers

      unless Net::HTTPSuccess === response
        raise "#{response.code}: #{response.body}"
      end
    end
  end
end
