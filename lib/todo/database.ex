defmodule Todo.Database do
  use GenServer

  # Compile-time constant (starts with `@`)
  @db_folder "./persist"

  # Interface function: Start server
  def start do
    GenServer.start(
      __MODULE__,
      nil,
      name: __MODULE__ # `name` parameter allows to locally register server under specified name
    )
  end

  # Interface function: Stores some data by key
  def store(key, data) do
    # __MODULE__ used as pid, because server was registered locally during start
    GenServer.cast(__MODULE__, {:store, key, data})
  end

  # Interface function: Fetches value by key
  def get(key) do
    GenServer.call(__MODULE__, {:get, key})
  end

  @impl GenServer
  def init(_) do
    # Make sure folder exists
    File.mkdir_p!(@db_folder)
    {:ok, nil}
  end

  # Stores data into a file
  @impl GenServer
  def handle_cast({:store, key, data}, state) do
    key
    |> file_name()
    |> File.write!(:erlang.term_to_binary(data)) # TODO: Serialization?

    {:noreply, state}
  end

  # Fetches data from a file
  @impl GenServer
  def handle_call({:get, key}, _, state) do
    data = case File.read(file_name(key)) do
      {:ok, contents} -> :erlang.binary_to_term(contents)
      _ -> nil
    end

    {:reply, data, state}
  end

  # Generates full file name by given key
  # Note: Use `defp` to define private function
  defp file_name(key) do
    Path.join(@db_folder, to_string(key))
  end
end
