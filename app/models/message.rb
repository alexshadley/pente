# this class needs to be an ActiveRecord in order for Cable Ready to broadcast to it *shrug*
class Message
  attr_accessor :user
  # session id of red player, nil if red player not yet present
  attr_accessor :text
  # session id of blue player, nil if blue player not yet present

  def initialize(user, text)
    @user = user
    @text = text
  end
end