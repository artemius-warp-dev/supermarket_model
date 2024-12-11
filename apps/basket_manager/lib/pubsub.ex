defmodule BasketManager.PubSub do
  @topic :basket_server_events

  ## Subscribe to the topic
  def subscribe() do
    :pg.join(@topic, self())
  end

  ## Broadcast an event
  def broadcast(event) do
    :pg.broadcast(@topic, event)
  end
end
