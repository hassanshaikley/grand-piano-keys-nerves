defmodule HelloNerves.Scene.Home do
  use Scenic.Scene
  require Logger

  alias Scenic.Graph

  import Scenic.Primitives
  # import Scenic.Components

  @note """
    This is a very simple starter application.

    If you want a more full-on example, please start from:

    mix scenic.new.example
  """

  @text_size 24

  # ============================================================================
  # setup

  # --------------------------------------------------------
  def init(scene, _param, _opts) do
    Process.flag(:trap_exit, true)

    # get the width and height of the viewport. This is to demonstrate creating
    # a transparent full-screen rectangle to catch user input
    {width, height} = scene.viewport.size

    Scenic.ViewPort.Input.capture(scene.viewport, [:key], []) |> IO.inspect()

    # show the version of scenic and the glfw driver
    scenic_ver = Application.spec(:scenic, :vsn) |> to_string()
    driver_ver = Application.spec(:scenic_driver_local, :vsn) |> to_string()

    info = "scenic: v#{scenic_ver}\nscenic_driver_local: v#{driver_ver}"

    scene = push_graph(scene, main_page())

    scene = Map.put(scene, :loop_iteration, 0)

    graph_table = :ets.new(:game_graph, [:set])

    scene = Map.put(scene, :graph_table, graph_table)
    {:ok, scene}
  end

  def terminate(_reason, _) do
    IO.puts("KIllall")
    Audio.killall()
  end

  def handle_info(:loop, state) do
    loop_iteration = Map.get(state, :loop_iteration)

    Process.send_after(self(), :loop, 25)

    push_graph(state, game_page(state.graph_table, loop_iteration))

    state = Map.put(state, :loop_iteration, loop_iteration + 10)

    {:noreply, state}
  end

  def main_page() do
    Graph.build(font: :roboto, font_size: @text_size)
    |> rect({200, 50}, t: {10, 10}, id: :rect_in, fill: :blue, input: [:cursor_button])
    |> text("Start Game", t: {110, 45}, text_align: :center)
  end

  # I think always loop the same 4 keys, so make it look infinitely scrolling but place at
  # the top when you reach the bottom
  def game_page(table, loop_iteration) do
    [game] = :ets.lookup(table, "graph")
    game = elem(game, 1)

    game = put_in(game.primitives[1].transforms.translate, {100, 100 + loop_iteration})
    # Graph.build(font: :roboto, font_size: @text_size)
    # |> all_rects()

    game
  end

  # The button to start game
  def handle_input({:cursor_button, {:btn_left, 1, [], _}}, _context, scene) do
    # Press button to start game

    graph =
      Graph.build(font: :roboto, font_size: @text_size)
      |> all_rects()

    # Click hte ubtton so insert
    :ets.insert(scene.graph_table, {"graph", graph})

    scene = push_graph(scene, game_page(scene.graph_table, 0))

    {:noreply, scene}
  end

  # TBH this is for the laptop side, not sure yet if can associate this with gpio
  # def handle_put({:key, {:key_1, 1, []}}, _context, scene) do
  #   # Start the loop, the first key will always be the first

  #   {:noreply, scene}
  # end

  def handle_input(event, _context, scene) do
    # Logger.info("Received event: #{inspect(event)}")
    # IO.puts("Input received")
    # IO.inspect(event)

    elem(event, 0)

    with {:error, :started} <- start_game(scene) do
      # Generate a random sequence of keys for the game

      # scene = push_graph(scene, game_page(scene.graph_table, 0))
      {:noreply, scene}
    else
      _ ->
        {:noreply, scene}
    end
  end

  defp handle_starting_input(event) do
    event_info = elem(event, 1)

    if match?({:key_1, 1, []}, event_info) do
      {:already_started}
    end
  end

  def play_backing_track() do
    file_name = "just_classical.wav"

    Audio.play(file_name)
  end

  # Generates a random sequence starting from zero, the first key is always zero because simplicity
  defp generate_game_keys() do
    [0] ++
      Enum.map(1..25, fn i ->
        Enum.random([0, 1, 2, 3])
      end)
  end

  # generates all the rectangles
  defp all_rects(graph) do
    graph
    |> group(
      fn g ->
        generate_game_keys()
        |> Enum.with_index()
        |> Enum.reduce(g, fn curr, acc ->
          key = elem(curr, 0)
          # Key is 1-4, like piano key 1, 2, 3 or 4
          index = elem(curr, 1)
          x_offset = 140 + (key - 1) * 170
          y_offset = 200 - 200 * index

          rect(acc, {150, 198},
            t: {x_offset, y_offset},
            id: :rect_in,
            fill: :white
          )
        end)
      end,
      translate: {100, 100},
      font: :roboto
    )
  end

  defp start_game(scene) do
    if scene.loop_iteration == 0 do
      Process.send(self(), :loop, [])

      :ok
    else
      {:error, :started}
    end
  end
end
