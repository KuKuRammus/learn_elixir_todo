defmodule Todo.Cache do
  # Interface function: Start cache supervisor
  def start_link() do
    IO.puts("Starting Todo.Cache")
    # Use Cache as a dynamic supervisor
    # DynamicSupervisor allows to dynamically add child processes to it
    DynamicSupervisor.start_link(
      name: __MODULE__,
      strategy: :one_for_one
    )
  end

  # Interface function: get server process by name
  def server_process(todo_list_name) do
    case start_child(todo_list_name) do
      {:ok, pid} -> pid
      {:error, {:already_started, pid}} -> pid
    end
  end

  defp start_child(todo_list_name) do
    # Dynamically start new child
    DynamicSupervisor.start_child(
      __MODULE__,
      {Todo.Server, todo_list_name} # Child specification
    )
  end

  def child_spec(_) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, []},
      type: :supervisor
    }
  end

end
