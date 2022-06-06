# Brings compile time helpers
# TODO: It is deprecated, use Config module instead
import Config

# Adds an application's environment value
config :todo,
  http_port: 5454

import_config "#{config_env()}.exs"
