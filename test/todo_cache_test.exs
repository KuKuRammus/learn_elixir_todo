# Note that test files must end with _test.exs. .exs indicates that file won't be compiled
# Unit tests can be run by calling `mix test`
defmodule TodoCacheTest do
  use ExUnit.Case # Use ex_unit module behaviour for testing

  # By using ex_unit module, `test` macro is defined
  test "server_proccess" do
    {:ok, cache} = Todo.Cache.start()
    bob_pid = Todo.Cache.server_process(cache, "bob")

    # Assert macro also provided by ex_unit
    assert bob_pid != Todo.Cache.server_process(cache, "alice")
    assert bob_pid == Todo.Cache.server_process(cache, "bob")
  end

  test "todo operations" do
    # Create new todo server for alice
    {:ok, cache} = Todo.Cache.start()
    alice = Todo.Cache.server_process(cache, "alice")

    # Add entry
    Todo.Server.add_entry(alice, %{date: ~D[2022-06-02], title: "Test"})
    entries = Todo.Server.entries(alice, ~D[2022-06-02])

    # Assert can check matching expressions too
    assert [%{date: ~D[2022-06-02], title: "Test"}] = entries
  end

end
