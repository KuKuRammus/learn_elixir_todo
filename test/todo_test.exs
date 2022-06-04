# Note that test files must end with _test.exs. .exs indicates that file won't be compiled
# Unit tests can be run by calling `mix test`
defmodule TodoCacheTest do
  use ExUnit.Case # Use ex_unit module behaviour for testing

  # By using ex_unit module, `test` macro is defined
  # test "server_proccess" do
  #   {:ok, cache} = Todo.Cache.start()
  #   bob_pid = Todo.Cache.server_process(cache, "bob")

  #   # Assert macro also provided by ex_unit
  #   assert bob_pid != Todo.Cache.server_process(cache, "alice")
  #   assert bob_pid == Todo.Cache.server_process(cache, "bob")
  # end

  # TODO: Subsequent tests will fail, because test generates side effect, which is not cleared
  # test "todo operations" do
  #   # Create new todo server for alice
  #   {:ok, cache} = Todo.Cache.start()
  #   alice = Todo.Cache.server_process(cache, "alice")

  #   # Add entry
  #   Todo.Server.add_entry(alice, %{date: ~D[2022-06-02], title: "Test"})
  #   entries = Todo.Server.entries(alice, ~D[2022-06-02])

  #   # Assert can check matching expressions too
  #   assert [%{date: ~D[2022-06-02], title: "Test"}] = entries
  # end

  test "todo tests (supervisor with manual spec)" do
    # Start supervisor process and link to a caller
    {:ok, supervisor_pid} = Supervisor.start_link(
      # List of child specification
      # Each element of this list is a child specification that describes how child should be started and managed
      # When started supervisor will go through list and start each child according to the specification
      [
        # Child specification
        # See: https://hexdocs.pm/elixir/Supervisor.html#module-child-specification
        %{
          # Id of the child, used to distinguish child from any other child in the same supervisor
          id: Todo.Cache,

          # How to start child {module, start_function, list_of_arguments}
          # Start function must start and link the process
          start: {Todo.Cache, :start_link, [nil]}
        }
      ],

      # Supervisor strategy (aka restart-strategy). Note that restart means respawn
      # :one_for_one - If child terminates, another child should be started in its place
      strategy: :one_for_one
    )

    # Get alice todo server
    alice = Todo.Cache.server_process("alice")

    # Add entry
    Todo.Server.add_entry(alice, %{date: ~D[2022-06-02], title: "Test"})
    entries = Todo.Server.entries(alice, ~D[2022-06-02])

    # Assert can check matching expressions too
    assert [%{date: ~D[2022-06-02], title: "Test"}] = entries
  end

  test "todo tests (supervisor spec from GenServer)" do
    # Start supervisor process and link to a caller
    {:ok, supervisor_pid} = Supervisor.start_link(
      # List of child specification
      # Each element of this list is a child specification that describes how child should be started and managed
      # When started supervisor will go through list and start each child according to the specification
      [
        # Child specification can also be taken from itself
        # To do this, pass {module_name, arg}
        # When starting, Supervisor will invoke module_name.child_spec(arg) to fetch specification
        # Default implementation of `child_spec` is provided by GenServer
        {Todo.Cache, nil}
      ],

      # Supervisor strategy (aka restart-strategy). Note that restart means respawn
      # :one_for_one - If child terminates, another child should be started in its place
      strategy: :one_for_one
    )

    # Get bob todo server
    bob = Todo.Cache.server_process("bob")

    # Add entry
    Todo.Server.add_entry(bob, %{date: ~D[2022-06-02], title: "Test"})
    entries = Todo.Server.entries(bob, ~D[2022-06-02])

    # Assert can check matching expressions too
    assert [%{date: ~D[2022-06-02], title: "Test"}] = entries
  end

end
