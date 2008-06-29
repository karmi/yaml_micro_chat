require File.join( File.dirname(__FILE__), '..', 'chat.rb' )
require 'sinatra/test/unit'

class Chat
  # Let's use another file for testing, obviously...
  @@yaml_file = File.join( File.dirname(__FILE__), 'messages.yml' )
end

class ChatTest < Test::Unit::TestCase
  
  def test_should_start_chat_properly
    assert_nothing_raised { Chat.start }
    get_it '/'
    assert @response.body.include?('<title>Micro Chat Based on Sinatra and YAML</title>')
  end
  
  def test_should_read_messages_from_yaml_upon_start
    get_it '/'
    assert_equal 3, Chat.messages.size
    assert_equal 'Hello from Safari', Chat.messages.last[:message]
  end
  
  def test_should_save_posted_message
    message = {:author => "Test", :message => "Assert+tested!"}
    post_it '/speak', message
    assert_equal 4, Chat.messages.size
    assert File.read( Chat.send(:class_variable_get, '@@yaml_file') ).include?('Assert tested!'), 
            "Message posted from test is not in YAML"
    undo_changes( message )
  end
  
  private
  
  def undo_changes(message)
    yaml_file = Chat.send(:class_variable_get, '@@yaml_file')
    messages = Chat.send(:class_variable_get, '@@messages')
    messages.reject! { |m| m[:author] == 'Test'  }
    File.open(yaml_file, 'w') { |f| f << messages.to_yaml }
  end

end