defmodule Todo.Database do
  use GenServer

  # Compile-time constant (starts with `@`)
  @db_folder "./persist"
  @worker_count 3

  # Interface function: Start server
  def start_link do
    IO.puts("Starting Todo.Database")
    GenServer.start_link(
      __MODULE__,
      nil,
      name: __MODULE__ # `name` parameter allows to locally register server under specified name
    )
  end

  # Interface function: Stores some data by key
  def store(key, data) do
    # Fetch worker and delegate cast to it
    key
    |> choose_worker()
    |> Todo.DatabaseWorker.store(key, data)
  end

  # Interface function: Fetches value by key
  def get(key) do
    # Fetch worker and delegate call to it
    key
    |> choose_worker()
    |> Todo.DatabaseWorker.get(key)
  end

  # Interface function: Fetches worker by name
  defp choose_worker(key) do
    GenServer.call(__MODULE__, {:choose_worker, key})
  end

  @impl GenServer
  def init(_) do
    # Make sure folder exists
    File.mkdir_p!(@db_folder)

    # Keepp map of workers as a state, all read/write operations will be delegated to them
    {:ok, start_workers()}
  end

  # Fetches worker for a specific key
  @impl GenServer
  def handle_call({:choose_worker, key}, _, workers) do
    # Compute key's numerical hash and normalize it to fall in [0, @worker_count - 1]
    worker_key = :erlang.phash2(key, @worker_count)
    {:reply, Map.get(workers, worker_key), workers}
  end

  # Starts pool of workers
  defp start_workers() do
    # This is comprehention which stores results into a map
    for index <- 1..@worker_count, into: %{} do
      {:ok, pid} = Todo.DatabaseWorker.start_link(@db_folder)
      {index - 1, pid}
    end
  end

end
