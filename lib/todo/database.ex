defmodule Todo.Database do
  # Compile-time constant (starts with `@`)
  @db_folder "./persist"
  @worker_count 5

  def start_link() do
    File.mkdir_p!(@db_folder)

    # Create list of child specification
    children = Enum.map(1..@worker_count, &worker_spec/1)

    # Start supervisor
    Supervisor.start_link(children, strategy: :one_for_one)
  end

  # Provides worker child spec used by the supervisor
  defp worker_spec(worker_id) do
    # {module, args}
    default_worker_spec = {Todo.DatabaseWorker, {@db_folder, worker_id}}

    # Child spec used to generate child spec
    Supervisor.child_spec(default_worker_spec, id: worker_id)
  end

  # Because Database is now a supervisor, this function is required to define how this supervisor manages it
  def child_spec(_) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, []},

      # Define that this is a supervisor
      type: :supervisor
    }
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

  # Fetches worker id by name
  defp choose_worker(key) do
    :erlang.phash2(key, @worker_count)
  end

end
