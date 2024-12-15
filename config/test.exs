import Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :gateway, GatewayWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "lWm5OchjiuyX8xFq+M2M4wmibJyCv4mhI8xn/hwLczwOJ5bOMR3KTdhghF0gK9uk",
  server: false

# In test we don't send emails
config :gateway, Gateway.Mailer, adapter: Swoosh.Adapters.Test

# Disable swoosh api client as it is only required for production adapters
config :swoosh, :api_client, false

# Print only warnings and errors during test
config :logger, level: :error

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime

config :gateway, :message_broker, MessageBrokerMock
config :message_broker, :basket_manager, BasketManagerMock
config :message_broker, :cluster_discovery, ClusterDiscoveryMock

# config :product_manager, :strategies, %{
#   GR1: %{module: ProductManager.GR1Strategy, price: 311, amount: 0},
#   SR1: %{module: ProductManager.SR1Strategy, price: 500, amount: 0},
#   CF1: %{module: ProductManager.CF1Strategy, price: 1123}
# }
