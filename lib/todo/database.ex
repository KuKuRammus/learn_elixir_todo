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

    # Keep 3 workers in state
    {:ok, {
      Todo.DatabaseWorker.start(@db_folder),
      Todo.DatabaseWorker.start(@db_folder),
      Todo.DatabaseWorker.start(@db_folder),
    }}
  end

  @impl GenServer
  def handle_cast({:store, key, data}, workers) do
    Todo.DatabaseWorker.store(
      choose_worker(workers, key),
      key,
      data
    )

    {:noreply, workers}
  end

  @impl GenServer
  def handle_call({:get, key}, _, workers) do
    data = Todo.DatabaseWorker.get(
      choose_worker(workers, key),
      key
    )

    {:reply, data, workers}
  end

  defp choose_worker(worker_list, name) do
    # Compute numerical hash from string and normalize to fall in range [0, 2]
    index = :erlang.phash2(name, 3)
    {:ok, worker_pid} = elem(worker_list, index)
    worker_pid
  end

end
