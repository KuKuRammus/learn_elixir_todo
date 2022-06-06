defmodule Todo.Application do
  # Use application behaviour
  use Application

  def start(_, _) do
    Todo.System.start_link()
  end
end
