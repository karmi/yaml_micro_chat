require "rubygems"
require "yaml"            # ... or where we will store the chat messages ...
require "ftools"          # ... or we wanna access the filesystem ...
require "sinatra"         # ... or Classy web-development dressed in DSL, http://sinatrarb.com

# Let's configure Sinatra logging in production
# configure :production do
#   log = File.new("sinatra.log", "a")
#   STDERR.reopen(log)
#   STDOUT.reopen(log)
# end

# -----------------------------------------------------------------------------

# = Singleton object to hold the chat 'server'
# 
class Chat
  
  @@yaml_file = File.join( File.dirname(__FILE__), 'messages.yml' )
    
  # Initializes the chat
  def self.start
    puts "Starting chat server..."
    load_messages
    raise 'YAML file not writable' unless File.writable? @@yaml_file
  end

  # Load the messages from file and send the new ones in response
  def self.listen(from=0)
    start unless @@messages
    # puts "* | Load messages from time: #{Time.at(from.to_i)}"
    # puts "  | #{@@messages.inspect}"
    @@messages.clone.delete_if { |m| m[:created_at].to_i <= from.to_i if m[:created_at] } # Kick out old messages
  end

  # Write the message to file
  def self.speak(author='', message='Testing the chat...')
    # puts ">>> #{author} wants to say #{message}"
    tmpfile = File.join( File.dirname(__FILE__), 'messages.tmp' )
    File.open(tmpfile, 'w') do |f| 
      f << ( @@messages << { :author => author, :message => message, :created_at => Time.now.to_i } ).to_yaml 
    end
    File.copy(tmpfile, @@yaml_file) # We have to do an 'atomic write' (Google it :)
    File.delete(tmpfile)
  end
  
  def self.messages
    @@messages
  end
      
  private
  
  # Load messages from YAML
  def self.load_messages
    # puts "Reading messages from YAML file"
    @@messages = YAML.load_file( @@yaml_file )
  end
  
end#Chat


# -----------------------------------------------------------------------------

# == Helpers

helpers do
  
  def human_date(t)
    Time.at(t).strftime('%m/%d').gsub(/0(\d)/, '\1') +
    '&nbsp;' + 
    Time.at(t).strftime('%H:%M')
  end
  
end


# == 'Routing' & 'Controllers' of the application

# Main screen
get '/' do
  Chat.start
  @messages = Chat.messages
  @remote_ip = self.request.env['REMOTE_ADDR']
  erb :index
end

# Listen for messages in chat
get '/listen' do
  out = ""
  Chat.listen(params[:from]).each do |m| 
    out << "<p id=\"#{m[:created_at]}\"><strong>#{m[:author]}</strong> <em>says</em> <span>#{m[:message]}</span><span class='d'> @ #{human_date(m[:created_at])}</span></p>"
  end
  out
end

# Post messages to chat
post '/speak' do
  Chat.speak params[:author], params[:message] unless params[:message] == '' or params[:author] == ''
  redirect '/' unless self.request.env['HTTP_X_REQUESTED_WITH'] and 
                      self.request.env['HTTP_X_REQUESTED_WITH'].scan(/XML/) # Don't redirect Ajax request...
end

