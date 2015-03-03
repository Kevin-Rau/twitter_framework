require_relative '../core/TwitterRequest'

class UsersProfileBanner < TwitterRequest

  def initialize(args)
    super args
  end

  def request_name
    "UsersProfileBanner"
  end

  def twitter_endpoint
    "/users/profile_banner"
  end

  def url
    'https://api.twitter.com/1.1/users/profile_banner.json'
  end

  def escaped_params
    params
  end

  def success(response)
    log.info("SUCCESS")
    users_data = JSON.parse(response.body)
    log.info("users profile banner information received.")
    yield users_data
  end

  def error(response)
    if response.code == 404
      puts "No users found"
      return
    end
    super
  end

end
