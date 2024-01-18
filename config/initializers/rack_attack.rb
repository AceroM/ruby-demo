# Block the following addresses
#   Rack::Attack.blocklist_ip("1.2.3.4")
#   Rack::Attack.blocklist_ip("1.2.0.0/16"

# Block suspicious requests
Rack::Attack.blocklist("ban pentesters and hackers") do |req|
  # After +maxretry+ blocked requests in +findtime+ minutes, block all requests from that IP for +bantime+ minutes.
  Rack::Attack::Fail2Ban.filter("pentesters-#{req.ip}", maxretry: 2, findtime: 30.minutes, bantime: 24.hours) do
    CGI.unescape(req.query_string) =~ %r{/etc/passwd} ||
      req.path.include?("/etc/passwd") ||
      req.path.include?("wp-admin") ||
      req.path.include?("wp-login") ||
      req.path.include?("super_admin")
  end
end

# Limit login and sign up
Rack::Attack.blocklist("limit login and sing up attempts") do |req|
  Rack::Attack::Allow2Ban.filter(req.ip, maxretry: 20, findtime: 2.minute, bantime: 1.hour) do
    # The count for the IP is incremented if the return value is truthy.
    (req.path == "/accounts/sign_in" ||
      req.path == "/accounts/") and req.post?
  end
end

# Thtrottle IP addresses with +limit+ req. / +period+ sec. limit
Rack::Attack.throttle("requests by ip", limit: 5, period: 1) do |req|
  req.ip
end

# Customize blocklist response
Rack::Attack.blocklisted_responder = lambda do |req|
  # Using 503 because it may make attacker think that they have successfully
  # DOSed the site. Rack::Attack returns 403 for blocklists by default
  [503, {}, ["Blocked"]]
end

# Customize throttle response
Rack::Attack.throttled_responder = lambda do |req|
  # NB: you have access to the name and other data about the matched throttle
  #  req.env['rack.attack.matched'],
  #  req.env['rack.attack.match_type'],
  #  req.env['rack.attack.match_data'],
  #  req.env['rack.attack.match_discriminator']
  # Using 503 because it may make attacker think that they have successfully
  # DOSed the site. Rack::Attack returns 429 for throttling by default
  [503, {}, ["Server Error\n"]]
end
