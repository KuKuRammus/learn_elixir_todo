defmodule Todo.Database do
  # Compile-time constant (starts with `@`)
  @db_folder "./persist"
  @worker_count 5

  # Note: start_link was removed, becuase specification states that database should be
  #       started by invoking :poolboy.start_link

  # Because Database is now a supervisor, this function is required to define how this supervisor manages it
  def child_spec(_) do

    File.mkdir_p!(@db_folder)

    # Using poolboy library as pool library
    :poolboy.child_spec(
      # Child ID
      __MODULE__,

      # Pool options
      [
        name: {:local, __MODULE__}, # States that pool manager process should be locally registered
        worker_module: Todo.DatabaseWorker, # Specify module which will power each worker process
        size: @worker_count # Specify pool size
      ],

      # What arguments will be passed to each worker
      [@db_folder]
    )
  end

  # Interface function: Stores some data by key
  def store(key, data) do
    :poolboy.transaction( # Asks the pool for a single worker
      __MODULE__,
      fn worker_pid -> # Performs an operation using worker_pid
        Todo.DatabaseWorker.store(worker_pid, key, data)
      end
    ) # After lambda finishes, pid of the worker is returned to the pool
  end

  # Interface function: Fetches value by key
  def get(key) do
    :poolboy.transaction(
      __MODULE__,
      fn worker_pid ->
        Todo.DatabaseWorker.get(worker_pid, key)
      end
    )
  end

end
