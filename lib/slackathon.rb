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

  def self.report_errors?
    @report_errors = true unless defined?(@report_errors)
    !!@report_errors
  end

  def self.report_errors=(val)
    @report_errors = val
  end

  def self.raise_errors?
    !!@raise_errors
  end

  def self.raise_errors=(val)
    @raise_errors = val
  end
end
