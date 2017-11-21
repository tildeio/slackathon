Slackathon::Engine.routes.draw do
  post "commands" => "webhooks#command"
  post "interactions" => "webhooks#interaction"
end
