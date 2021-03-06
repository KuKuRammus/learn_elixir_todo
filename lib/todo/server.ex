defmodule Todo.Server do
  # Use gen_server behaviour (behaviours are similar to traits+interface to PHP?)
  use GenServer, restart: :temporary

  # After how long server should shutdown due to inactivity
  @expiry_idle_timeout :timer.seconds(10)

  # Interface function: start server
  def start_link(name) do
    # Start server and register it into registry
    GenServer.start_link(__MODULE__, name, name: via_tuple(name))
  end

  defp via_tuple(name) do
    Todo.ProcessRegistry.via_tuple({__MODULE__, name})
  end

  # Interface function: add new entry
  def add_entry(todo_server, new_entry) do
    GenServer.cast(todo_server, {:add_entry, new_entry})
  end

  # Interface function: get entry list by date
  def entries(todo_server, date) do
    GenServer.call(todo_server, {:entries, date})
  end

  # Implement init from gen_server (argument can be used to get data while starting server)
  @impl GenServer
  def init(list_name) do
    IO.puts("Starting Todo.Server - #{list_name}")
    {
      :ok,
      {list_name, Todo.Database.get(list_name) || Todo.List.new()}, # Try to fetch from database with fallback
      @expiry_idle_timeout
    }
  end

  # Implement handle_cast from gen_server (takes: request, current_state)
  @impl GenServer
  def handle_cast({:add_entry, new_entry}, {list_name, todo_list}) do
    new_state = Todo.List.add_entry(todo_list, new_entry)

    # Persist data
    Todo.Database.store(list_name, new_state)

    {:noreply, {list_name, new_state}, @expiry_idle_timeout} # Casts must return {:noreply, new_state} + optional timeout
  end

  # Implement handle_call from gen_server (takes: request, caller info(request ID, used internally), current_state)
  @impl GenServer
  def handle_call({:entries, date}, _, {list_name, todo_list}) do
    entries = Todo.List.entries(todo_list, date)
    {
      :reply,
      entries,
      {list_name, todo_list},
      @expiry_idle_timeout # Add timeout parameter
      } # Calls must return {:reply, response, new_state}
  end

  # Handle timeout message
  @impl GenServer
  def handle_info(:timeout, {name, todo_list}) do
    IO.puts("Stopping to-do server #{name}")
    {:stop, :normal, {name, todo_list}}
  end

end
