defmodule HelloNerves.Components.Debug do
  use Scenic.Component, has_children: false
  import Scenic.Primitives

  alias Scenic.{Graph, Primitive}

  def create_graph(msg) do
    Graph.build()
    |> text("Debug: #{msg}",
      fill: :red,
      font: :roboto_mono,
      font_size: 18,
      id: :debug
    )
  end

  def validate(data) do
    {:ok, data}
  end

  def init(scene, _params, _opts) do
    graph = create_graph("?")

    Scenic.PubSub.subscribe(:debug)

    scene = push_graph(scene, graph)

    {:ok, scene}
  end

  # Do nothing
  def handle_info(
        {{Scenic.PubSub, :registered}, {:debug, [registered_at: _registered_at]}},
        scene
      ) do
    {:noreply, scene}
  end

  # Button from breadboard
  # The first button when the scene is 0
  def handle_info(
        {{Scenic.PubSub, :data}, {:debug, message, _timestamp}},
        scene
      ) do
    scene =
      scene
      |> push_graph(create_graph(message))

    {:noreply, scene}
  end

  # There are ways to update a graph as well
  # But just keeping it simple / doing what works
  # def handle_update(message, opts, scene) do
  #   scene =
  #     scene
  #     |> push_graph(create_graph(message))

  #   {:noreply, scene}
  # end

  def child_spec({args, opts}) do
    %{
      id: make_ref(),
      start:
        {Scenic.Scene, :start_link, [__MODULE__, args, Keyword.put_new(opts, :name, __MODULE__)]},
      type: :worker,
      restart: :permanent,
      shutdown: 500
    }
  end
end
