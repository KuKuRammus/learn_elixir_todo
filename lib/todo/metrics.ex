defmodule Todo.Metrics do
  # Make this module inherit task behaviour
  use Task

  def start_link(_) do
    Task.start_link(&loop/0) # Start loop in a non-awaited task
  end

  defp loop() do
    Process.sleep(:timer.seconds(10))
    IO.inspect(collect_metrics())
    loop() # Tail call do not cause recursion
  end

  defp collect_metrics() do
    [
      memory_usage: :erlang.memory(:total),
      process_count: :erlang.system_info(:process_count)
    ]
  end
end
