# Stores mapping :name => server_pid for the all existing todo servers
defmodule Todo.Cache do
  use GenServer

  # Interface function: Start cache server
  def start do
    GenServer.start(__MODULE__, nil)
  end

  # Interface function: get server process by name
  def server_process(cache_pid, todo_list_name) do
    GenServer.call(cache_pid, {:server_process, todo_list_name})
  end


  @impl GenServer
  def init(_) do
    Todo.Database.start() # Temp: Start the database
    {:ok, %{}} # Store relation between name and server_pid as a map
  end

  @impl GenServer
  def handle_call({:server_process, todo_list_name}, _, todo_servers) do
    # Fetch server_pid by name
    case Map.fetch(todo_servers, todo_list_name) do
      # Found
      {:ok, todo_server} ->
        {:reply, todo_server, todo_servers}

      # Not found
      :error ->
        # Start new server with a provided name if not found
        {:ok, new_server} = Todo.Server.start(todo_list_name)

        # Respond with a newly created server, and update the cache server state
        {
          :reply,
          new_server,

          # To create new key on the map, `put` function from built-in module `Map` is used
          Map.put(todo_servers, todo_list_name, new_server)
        }
    end
  end
end
