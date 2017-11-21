# Slackathon

A simple way to build Slack interations inside a Rails app. Check out our
[blog post](http://blog.skylight.io/the-slackathon) for the story behind
this gem!

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'slackathon'
```

Also, add this to `config/routes.rb`

```ruby
mount Slackathon::Engine => "/slack"
```

And then execute:

```bash
$ bundle
```

## Development Workflow

### Basic Slack Command

1. Set up https://ngrok.com/

   This gives you a public URL for Slack to reach your development machine.
   On a Mac, you can also install it via `brew cask install ngrok`.

   Assuming the Rails app is already running on port 3000, you can expose the
   Rails app with `ngrok http 3000`, which should give you a public URL like
   `http://00bea6f5.ngrok.io.`

1. Create a Slack app at https://api.slack.com/apps

   The "App Name" will be used as the display name when the app is replying to
   commands.

   To get everything working perfectly, you probably want to mirror all the
   settings on the production app, the here are the most important bits.

1. Go to "Your App > Settings > Install App" to add it to your Slack.

1. Create your command under "Your App > Features > Slash Commands"

   - The command is whatever you would type after the "/" in Slack, e.g.
     `/monkey`.
   - The request URL should be `http://00bea6f5.ngrok.io/slack/commands`.
   - You probably want to turn on "Escape channels, users, and links sent to
     your app" which will make it easier to parse @mentions and #channels.

1. Create a `monkey_command.rb` in `app/slack`

   - The name of the file (`monkey_command.rb`) and the class name (`MonkeyCommand`)
     has to match the name of the command (`/monkey`).
   - You should inherit from the `Slackathon::Command` class.
   - You have access to the `params` hash.
   - At minimum, you will need to implement the `call` method.
   - Example:
     ```ruby
     class MonkeyCommand < Slackathon::Command
       def call
         {
           response_type: "in_channel",
           text: "#{user} said #{params[:text]} :see_no_evil:"
         }
       end

       private

       def user
         "<@#{params[:user_id]}>"
       end
     end
     ```
  - See https://api.slack.com/slash-commands#responding_to_a_command and
    https://api.slack.com/docs/message-formatting for more documentation about
    the responses you can send.

### Adding Buttons

In this section, we will modify the `MonkeyBot` and let the user pick which
monkey emoji to use.

1. Enable "Your App > Features > Interactive Components"

   - This is required to support buttons, menus and dialogs.
   - The request URL should be `http://00bea6f5.ngrok.io/slack/interactions`.
   - You probably won't need to worry about "Options Load URL".

1. Instead of immediately posting to the channel, we will reply to the user
   only, asking for their emoji preference:

   ```ruby
   class MonkeyCommand < Slackathon::Command
     def call
       {
         response_type: "ephemeral",
         attachments: [{
           callback_id: "monkey",
           text: "Please pick a style",
           actions: [{
             type: "button",
             text: "Click to use :see_no_evil:",
             name: "post_in_channel",
             value: "#{params[:text]} :see_no_evil:"
           }, {
             type: "button",
             text: "Click to use :hear_no_evil:",
             name: "post_in_channel",
             value: "#{params[:text]} :hear_no_evil:"
           }, {
             type: "button",
             text: "Click to use :speak_no_evil:",
             name: "post_in_channel",
             value: "#{params[:text]} :speak_no_evil:"
           }]
         }]
       }
     end

     def post_in_channel(value)
       # do something with value, see below...
     end
   end
   ```

   - Here, we are using the `ephemeral` response type (as opposed to `in_channel`
     as we did previously), which makes the response visible only to the user
     who sent the command.
   - In addition to the message text, we are including a few buttons in the
     `attachments` array.
   - The `callback_id` need to match the name of your command (e.g. `monkey` in
     this case).
   - The `actions` array has the button(s) you want to include.
   - The `text` is the label of the button (e.g. "Click me!!!").
   - The `name` is the name of the method to call when the button is clicked
     (see below).
   - The `value` is an optional string that will be passed to the method (see
     below).
   - See https://api.slack.com/interactive-messages and https://api.slack.com/dialogs
     for more documentation.

1. When the user clicks on one of the buttons, it will call the method you
   specified:

   ```ruby
   class MonkeyCommand < Slackathon::Command
     # def call ...
     def post_in_channel(value)
       {
         response_type: "in_channel",
         delete_original: true,
         text: "<@#{params[:user][:id]}> said #{value}"
       }
     end
   end
   ```

   Here, `value` is the string that we attached to the original buttons.

## Promoting to Production

1. Remove the command from your development Slack app.

1. Create a production Slack app and your command/interactive component
   following the instructions above (with the URLs pointing to your
   production Rails app).

1. Find the "Verification Token" from `https://api.slack.com/apps/<your app>`.
   Assign its value to the `SLACK_VERIFICATION_TOKEN` ENV variable in
   your production environment (or set it with `Slackathon.verification_token = ...`).

1. Make sure your Active Job adapter is configured to process the `slack`
   queue (e.g. `bundle exec sidekiq -q default -q slack ...`). Alternatively,
   you can change the queue with `Slackathon.queue = ...`.

1. Deploy your changes!

## License
The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
