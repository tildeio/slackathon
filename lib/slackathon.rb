require "slackathon/engine"
require "slackathon/command"

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
end
