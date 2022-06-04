defmodule Todo.System do
  # Use this module as a callback module for supervisor
  use Supervisor

  def start_link do
    # Start supervisor with Todo.System being used as a callback module
    Supervisor.start_link(__MODULE__, nil)
  end

  # Implement callback for the supervisor callback module
  @impl Supervisor
  def init(_) do
    # Start cache in supervisor process
    # See blocks in tests to check how supervisor child specification can be configured
    # NOTE: Processes are not restarted indefinetely. There is a default restart freq. - 3 times in 5 sec.
    Supervisor.init(
      [Todo.Cache],
      strategy: :one_for_one
    )
  end
end
