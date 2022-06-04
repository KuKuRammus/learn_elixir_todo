defmodule Todo.ProcessRegistry do
  def start_link() do
    # Note: Registry is a key value storage for processes
    # Start the registy with name equals to current module name
    # Set key behaviour to unique, meaning one key contains one mapping
    Registry.start_link(name: __MODULE__, keys: :unique)
  end

  # Can be used to create appropriate via-tuple that registers process in this registry (even by other modules)
  def via_tuple(key) do
    # Via tuple is a mechanism that allows to use third-party registry to register
    # OTP-compliant processes such as GenServer and supervisor
    # Has shape of {:via, some_module, some_arg}
    {:via, Registry, {__MODULE__, key}}
  end

  # Provides custom child_spec for the supervisor
  def child_spec(_) do
    # Beause registry is a process, it should run under supervisor
    Supervisor.child_spec(
      Registry,
      id: __MODULE__, # Register be the ID of the module in the supervisor

      # Override start behaviour to {USE_THIS_MODULE, CALL_START_LINK, WITH_NO_PARAMETERS}
      start: {__MODULE__, :start_link, []}
    )
  end
end
