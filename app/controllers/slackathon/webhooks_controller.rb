module Slackathon
  class WebhooksController < ApplicationController
    before_action :verify_token

    def command
      command = payload[:command][1..-1]
      klass = "#{command}_command".classify.constantize

      SlackCommandJob.perform_later(klass.name, "command", payload.to_unsafe_h)

      head :ok
    end

    def interaction
      command = payload[:callback_id]
      klass = "#{command}_command".classify.constantize

      SlackCommandJob.perform_later(klass.name, "interaction", payload)

      head :ok
    end

    private

    def payload
      @payload ||= params[:payload] ? JSON.parse(params[:payload]).with_indifferent_access : params
    end

    def verify_token
      expected_token = Slackathon.verification_token
      actual_token = payload.delete(:token)

      if Rails.env.production? || expected_token
        raise "Incorrect slack verification token" unless expected_token == actual_token
      end
    end
  end
end
