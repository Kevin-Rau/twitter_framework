require_relative '../requests/UsersProfileBanner'

require 'trollop'

USAGE = %Q{
users_lookup: returns profile banner information for a given user.

Usage:

  ruby users_lookup.rb <options> [user_id|sceen_name]
  ruby users_lookup.rb <options> screen_name:<screen_name>
  ruby users_lookup.rb <options> user_id:<user_id>

  <user_id>    : Twitter User ID.
  <screen_name>: Twitter Screen Name.


The following options are required:

}

def parse_command_line

  options = {type: :string, required: true}

  opts = Trollop::options do
    version "get_profile_banner 0.1 (c) 2015 Kenneth M. Anderson updated by Kevin Rau"
    banner USAGE
    opt :props, "OAuth Properties File", options
  end

  unless File.exist?(opts[:props])
    Trollop::die :props, "must point to a valid oauth properties file"
  end

  opts[:screen_name] = ARGV[0]
  opts
end

if __FILE__ == $0

  STDOUT.sync = true

  input  = parse_command_line
  params = { screen_name: input[:screen_name] }
  data   = { props: input[:props] }

  args     = { params: params, data: data }

  twitter = UsersProfileBanner.new(args)

  puts "Display profile banner of the Twitter user: '#{input[:screen_name]}'"

  twitter.collect do |user|
    puts "#{user}\n"
    puts "#{user.size} user retrieved.\n"
  end

  puts "DONE."

end