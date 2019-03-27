#!/usr/bin/env ruby
# facebook-statuses
# $Revision: 66 $
# display Facebook status updates with Growl (OS X only)
# http://log.antiflux.org/grant/2007/04/30/facebook-status-notifications-with-growl

require 'open-uri'
require 'yaml'
require 'rss/2.0'

APPLICATION = "Facebook Status"
ICON        = File.join(ENV['HOME'], 'Pictures', 'facebook.jpg')
CONFIG      = File.join(ENV['HOME'], 'Library', 'Preferences',
                        'ca.granth.facebook-status')
KEEP_COUNT  = 10  # number of statuses to remember, per name
AGENT       = "Statusbot 1.0 (http://antiflux.org/~grant/code/os10/)"
MIN_STICKY  = 6   # make notifications sticky if you have at least this many

blacklist_on = true
blacklist = ['Nick Ledesma','Chrissy Esposito','Vickie Eisenstein','Keith Bodin','Scott Zimmerman','Jennifer Polfus Ellsworth']
whitelist_on = false
whitelist = ['Rachel Mays','Tomo Reisei']
# is_sticky = true

class Symbol                        
  def to_proc
    Proc.new{|*args| args.shift.__send__(self, *args)}
  end
end

def notify(message, opts = {})
  notifications = %q{{"Status", "Error"}}
  opts = {
    :type   => :status,
    :title  => "Facebook",
    :sticky => :sticky,
  }.merge(opts)
  message.gsub!(/\"/, '\"') # escape double quotes for AppleScript
  image = File.exist?(ICON) ? 
    %{image from location "#{ICON}"} : ""
  cmd = <<-END.gsub(/^\s+/m, '')
    /usr/bin/osascript <<AS
      tell application "GrowlHelperApp"
        register as application "#{APPLICATION}" \
          all notifications #{notifications} \
          default notifications #{notifications}
        notify with \
          name "#{opts[:type].to_s.capitalize}" \
          title "#{opts[:title]}" \
          description "#{message}" \
          application name "#{APPLICATION}" \
          #{image} \
          sticky False
      end tell
    AS
  END
  system(cmd)
end

def error(message)
  notify(message, :type => :error)
  exit
end

# load config file
config = YAML.load_file(CONFIG) rescue {}
config_as_loaded = YAML.load(config.to_yaml) # deep copy

# get RSS URL from config or command line
feed_url = ARGV[0] || config[:url]
error("No RSS URL given") if feed_url.nil?
config[:url] = feed_url

# fetch and parse
begin
  rss = open(feed_url, 'User-Agent' => AGENT).read
  feed = RSS::Parser.parse(rss, false)
rescue SocketError, Timeout::Error  # no network
  exit
rescue
  error("Failed to read '#{feed_url}'")
end

# find new entries, sorted by date
config[:seen] ||= {}
entries = feed.items.sort_by(&:pubDate).reject do |entry|
  config[:seen][entry.author] ||= []
  config[:seen][entry.author].member?(entry.guid.content)
end

# notify and add to list of seen statuses
sticky = entries.size >= MIN_STICKY
entries.each do |entry|
  # check blacklist
  if (blacklist_on and !blacklist.include?(entry.author)) or (whitelist_on and whitelist.include?(entry.author)) or (!whitelist_on and !blacklist_on)
    notify(entry.title, :sticky => sticky)
    config[:seen][entry.author].unshift(entry.guid.content)
  end
end

# truncate lists
config[:seen].each_value do |statuses|
  statuses = statuses[0...KEEP_COUNT]
end

# save config if changed
if config != config_as_loaded
  File.open(CONFIG, 'w') { |f| YAML.dump(config, f) }
end
