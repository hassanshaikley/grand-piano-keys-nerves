defmodule HelloNerves.Components.Score do
  use Scenic.Component, has_children: false
  import Scenic.Primitives

  alias Scenic.{Graph, Primitive}

  def create_graph(current_score) do
    Graph.build()
    |> text("Score: #{to_string(current_score)}",
      fill: :green,
      font: :roboto_mono,
      font_size: 18,
      id: :current_score
    )
  end

  def validate(data) do
    {:ok, data}
  end

  def init(scene, _params, _opts) do
    graph = create_graph(0)

    scene = push_graph(scene, graph)

    {:ok, scene}
  end

  def handle_call({:update_score, new_score}, _from, scene) do
    {:noreply, scene}
  end

  # There are ways to update a graph as well
  # But just keeping it simple / doing what works
  def handle_update(new_score, opts, scene) do
    scene =
      scene
      |> push_graph(create_graph(new_score))

    {:noreply, scene}
  end

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
