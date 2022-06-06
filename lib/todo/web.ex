defmodule Todo.Web do

  # Include Plug.Router behaviour
  use Plug.Router

  # Elixir macro invocation
  plug :match
  plug :dispatch

  # Call post macro
  # curl -d "" "http://localhost:5454/add_entry?list=bob&date=2018-12-19&title=Dentist"
  post "/add_entry" do
    # Decode input
    conn = Plug.Conn.fetch_query_params(conn)
    list_name = Map.fetch!(conn.params, "list")
    title = Map.fetch!(conn.params, "title")
    date = Map.fetch!(conn.params, "date") |> Date.from_iso8601!()

    # Perform operation
    list_name
    |> Todo.Cache.server_process()
    |> Todo.Server.add_entry(%{title: title, date: date})

    # Return response
    conn
    |> Plug.Conn.put_resp_content_type("text/plain")
    |> Plug.Conn.send_resp(200, "OK")
  end

  # curl "http://localhost:5454/entries?list=bob&date=2018-12-19"
  get "/entries" do
    conn = Plug.Conn.fetch_query_params(conn)
    list_name = Map.fetch!(conn.params, "list")
    date = Map.fetch!(conn.params, "date") |> Date.from_iso8601!()

    entries =
      list_name
      |> Todo.Cache.server_process()
      |> Todo.Server.entries(date)

    formatted_entries =
      entries
      |> Enum.map(&"#{&1.date} #{&1.title}")
      |> Enum.join("\n")

    conn
    |> Plug.Conn.put_resp_content_type("text/plain")
    |> Plug.Conn.send_resp(200, formatted_entries)
  end

  def child_spec(_) do
    # Provide spec to start server powered by plug and cowboy
    Plug.Adapters.Cowboy.child_spec(
      scheme: :http, # Server over http
      options: [ # Options
        port: Application.fetch_env!(:todo, :http_port), # Fetch env variable from config/config.exs
      ],
      plug: __MODULE__ # Some functions from this module will be invoked to handle the request
    )
  end
end
