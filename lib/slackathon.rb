require "slackathon/engine"
require "slackathon/command"
require "net/http"
require "uri"

module Slackathon
  def self.verification_token
    @verification_token ||= ENV["SLACK_VERIFICATION_TOKEN"]
  end

  def self.verification_token=(token)
    @verification_token = token
  end

  def self.queue
    @queue ||= "slack"
  end

  def self.queue=(queue)
    @queue = queue
  end

  def self.say(url, body)
    uri = URI(url)
    headers = { "Content-Type" => "application/json" }
    body = (String === body) ? body : body.to_json
    response = Net::HTTP.post uri, body, headers

    unless Net::HTTPSuccess === response
      raise "#{response.code}: #{response.body}"
    end
  end
end
