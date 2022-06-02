defmodule Todo.Server do
  # Use gen_server behaviour (behaviours are similar to traits+interface to PHP?)
  use GenServer

  # Interface function: start server
  def start do
    GenServer.start(__MODULE__, nil) # __MODULE__ will automatically transform to current module name
  end

  # Interface function: add new entry
  def add_entry(todo_server, new_entry) do
    GenServer.cast(todo_server, {:add_entry, new_entry})
  end

  # Interface function: get entry list by date
  def entries(todo_server, date) do
    GenServer.call(todo_server, {:entries, date})
  end

  # Implement init from gen_server (argument can be used to get data while starting server)
  @impl GenServer
  def init(_) do
    {:ok, Todo.List.new()}
  end

  # Implement handle_cast from gen_server (takes: request, current_state)
  @impl GenServer
  def handle_cast({:add_entry, new_entry}, todo_list) do
    new_state = Todo.List.add_entry(todo_list, new_entry)
    {:noreply, new_state} # Casts must return {:noreply, new_state}
  end

  # Implement handle_call from gen_server (takes: request, caller info(request ID, used internally), current_state)
  @impl GenServer
  def handle_call({:entries, date}, _, todo_list) do
    entries = Todo.List.entries(todo_list, date)
    {:reply, entries, todo_list} # Calls must return {:reply, response, new_state}
  end

end
