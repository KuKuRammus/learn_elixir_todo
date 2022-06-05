# Note: This is an example how todo server can be represented as an agent
# Note: It is better to start with GenServer first, and then downgrade if needed
defmodule Todo.ServerAgent do
  # Use agent behaviour (behaviours are similar to traits+interface to PHP?)
  # Note: always wrap agent in a module, because state is exposed, unlike gen server, where only defined messages are
  use Agent, restart: :temporary

  # Interface function: start server
  def start_link(name) do
    # Start agent with a state
    Agent.start_link(
      fn ->
        IO.puts("Starting todo server for #{name}")
        {name, Todo.Database.get(name) || Todo.List.new()}
      end,
      name: via_tuple(name)
    )

  end

  defp via_tuple(name) do
    Todo.ProcessRegistry.via_tuple({__MODULE__, name})
  end

  # Interface function: add new entry
  def add_entry(todo_server, new_entry) do
    # Async update of the agent state
    Agent.cast(todo_server, fn {name, todo_list} ->
      new_list = Todo.List.add_entry(todo_list, new_entry)
      Todo.Database.store(name, new_list)
      {name, new_list}
    end)
  end

  # Interface function: get entry list by date
  def entries(todo_server, date) do
    # Get agent state
    Agent.get(
      todo_server,
      fn {_name, todo_list} -> Todo.List.entries(todo_list, date) end
    )
  end
end
