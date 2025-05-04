defmodule HelloNerves.Components.Score do
  use Scenic.Component, has_children: false
  import Scenic.Primitives

  alias Scenic.{Graph, Primitive}

  require Logger

  @graph Graph.build()
         |> text("Score: 0",
           fill: :green,
           font: :roboto_mono,
           font_size: 18,
           id: :current_score
         )

  def validate(_), do: {:ok, nil}

  def init(scene, _params, _opts) do
    graph = @graph

    scene = push_graph(scene, @graph)

    {:ok, scene}
  end

  def handle_call({:update_score, new_score}, _from, scene) do
    Logger.info("UPDATING SCOREEE")
    graph = update(scene, new_score)

    push_graph(scene, @graph)
    {:noreply, scene}
  end

  def handle_event(event, from, scene) do
    Logger.info("handlign event")
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

  defp update(state, new_score) do
    Graph.build()
    |> text("Score: #{to_string(new_score)}",
      fill: :green,
      font: :roboto_mono,
      font_size: 18,
      id: :current_score
    )
  end
end
