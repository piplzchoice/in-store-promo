# Simple Role Syntax
# ==================
# Supports bulk-adding hosts to roles, the primary server in each group
# is considered to be the first unless any hosts have the primary
# property set.  Don't declare `role :all`, it's a meta role.

role :app, %w{deploy@104.236.182.64}
role :web, %w{deploy@104.236.182.64}
role :db,  %w{deploy@104.236.182.64}


# Extended Server Syntax
# ======================
# This can be used to drop a more detailed server definition into the
# server list. The second argument is a, or duck-types, Hash and is
# used to set extended properties on the server.

server '104.236.182.64', user: 'deploy', roles: %w{web app}, my_property: :my_value

set :default_env, { 
  'AWS_ACCESS_KEY' => 'AKIAIGBBLZ6KTIEL3ZOA',
  'AWS_DIRECTORY' => "ismp-live",
  'AWS_REGION' => "us-west-1",
  'AWS_SECRET_ACCESS_KEY' => "Hb8YGHKvdPKKEQCYNw3Z1gcpgBwcEfkEDGnbZGxA",
  'RACK_ENV' => "production",
  'RAILS_ENV' => "production",
  'SECRET_KEY_BASE' => "7dbfc7d55d44afdda3ff30b8071d40fc441697d4b5a1f2739248e791f82670b0014b25feee1799c6e1ffc684ded1cb5a767d576e882bdb8283bd054876e04f20",
  'SENDGRID_PASSWORD' => "felicia777",
  'SENDGRID_USERNAME' => "gregy",
}

# Custom SSH Options
# ==================
# You may pass any option but keep in mind that net/ssh understands a
# limited set of options, consult[net/ssh documentation](http://net-ssh.github.io/net-ssh/classes/Net/SSH.html#method-c-start).
#
# Global options
# --------------
#  set :ssh_options, {
#    keys: %w(/home/rlisowski/.ssh/id_rsa),
#    forward_agent: false,
#    auth_methods: %w(password)
#  }
#
# And/or per server (overrides global)
# ------------------------------------
# server 'example.com',
#   user: 'user_name',
#   roles: %w{web app},
#   ssh_options: {
#     user: 'user_name', # overrides user setting above
#     keys: %w(/home/user_name/.ssh/id_rsa),
#     forward_agent: false,
#     auth_methods: %w(publickey password)
#     # password: 'please use keys'
#   }
