module Sinatra
  module Flash
    module Style
      def styled_flash(key=:flash)
        return "" if flash(key).empty?
        id = (key == :flash ? "flash" : "flash_#{key}")
        close = '<button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>'
        messages = flash(key).collect {|message| "  <div class='alert alert-#{message[0]} alert-dismissable fade show' role='alert'><strong>#{message[0].capitalize}!</strong> #{message[1]}\n #{close}</div>\n"}
        "<div id='#{id}'>\n" + messages.join + "</div>"
      end
    end
  end
end
