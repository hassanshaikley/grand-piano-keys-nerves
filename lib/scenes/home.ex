defmodule HelloNerves.Scene.Home do
  use Scenic.Scene
  require Logger

  alias Scenic.Graph

  import Scenic.Primitives
  # import Scenic.Components

  @text_size 24
  # Easier to do this than deal with floats
  @fps 25

  @child_id :my_child_component
  @custom_event "custom_event"

  # ============================================================================
  # setup

  # --------------------------------------------------------
  def init(scene, _param, _opts) do
    Process.flag(:trap_exit, true)

    # get the width and height of the viewport. This is to demonstrate creating
    # a transparent full-screen rectangle to catch user input
    {width, height} = scene.viewport.size

    Scenic.ViewPort.Input.capture(scene.viewport, [:key], [])

    # show the version of scenic and the glfw driver
    scenic_ver = Application.spec(:scenic, :vsn) |> to_string()
    driver_ver = Application.spec(:scenic_driver_local, :vsn) |> to_string()

    info = "scenic: v#{scenic_ver}\nscenic_driver_local: v#{driver_ver}"

    scene = push_graph(scene, main_page())

    graph_table = :ets.new(:game_graph, [:set])

    scene = Map.put(scene, :graph_table, graph_table) |> Map.put(:current_score, 0)
    {:ok, scene}
  end

  def terminate(_reason, _) do
    Audio.killall()
  end

  def handle_info(:start_loop, state) do
    new_state = Map.put(state, :started_at, DateTime.utc_now())
    # Hopefully this starts after we set the start time..if not we may want to do some hacks
    send(self(), :loop)

    {:noreply, new_state}
  end

  def handle_info(:loop, state) do
    # Every 100 we step down
    # Kind of a hack to do this before doing any processing that might take a couple milliseconds
    # One other way would be to calculate how lon gthis fn takes and subtract that from the send_after time
    Process.send_after(self(), :loop, div(1000, @fps))

    push_graph(state, game_page(state.graph_table, state.started_at))

    # 120 bpm for mary had a litle lamb
    # 10 frames per secodn, need to move 1/5 of a key per frame
    # key height is ~ 200 (198), 200/5 = 40

    {:noreply, state}
  end

  def main_page() do
    Graph.build(font: :roboto, font_size: @text_size)
    |> rect({200, 50}, t: {10, 10}, id: :rect_in, fill: :blue, input: [:cursor_button])
    |> text("Start Game", t: {110, 45}, text_align: :center)
  end

  # I think always loop the same 4 keys, so make it look infinitely scrolling but place at
  # the top when you reach the bottom
  def game_page(table, started_at) do
    [{_, game}] = :ets.lookup(table, "graph")

    offset_y =
      if is_nil(started_at) do
        0
      else
        millsecond_diff_from_start =
          DateTime.diff(DateTime.utc_now(), started_at, :millisecond)

        # 500 milliseconds = move the full height of 200
        # 500 ms = 200
        # 1000ms = 400

        div(millsecond_diff_from_start * 20, 50)
      end

    game = put_in(game.primitives[1].transforms.translate, {100, 100 + offset_y})

    game
  end

  defp graph() do
    graph =
      Graph.build(font: :roboto, font_size: @text_size)
      |> all_rects()
      |> HelloNerves.Components.Score.add_to_graph(:init_data,
        translate: {670, 30},
        id: @child_id
      )
  end

  # The button to start game
  def handle_input({:cursor_button, {:btn_left, 1, [], _}}, _context, scene) do
    # Press button to start game

    # Click the button so insert
    :ets.insert(scene.graph_table, {"graph", graph()})

    scene = push_graph(scene, game_page(scene.graph_table, nil))

    {:noreply, scene}
  end

  # TBH this is for the laptop side, not sure yet if can associate this with gpio

  # When they press 1 on the laptop it creates
  # {:key, {:key_1, 0, []}} = event
  #
  @keys %{
    key_1: 1,
    key_2: 2,
    key_3: 3,
    key_4: 4
  }

  # 1 is down, 0 is up
  def handle_input({:key, {key, 1, []}}, _context, scene) do
    with {:error, :started} <- start_game(scene) do
      # If the game is start
      key = @keys[key]

      new_score = Game.press_key(key)

      update_child(scene, @child_id, new_score, [])

      {:noreply, scene}
    else
      _ ->
        scene = Map.put(scene, :started, true)
        {:noreply, scene}
    end
  end

  def handle_input(_, _context, scene) do
    {:noreply, scene}
  end

  def play_backing_track() do
    file_name = "mary_btrack_right.wav"

    Audio.play(file_name)
  end

  # generates all the rectangles
  defp all_rects(graph) do
    graph
    |> group(
      fn g ->
        Mary.keys()
        |> Enum.with_index()
        |> Enum.reduce(g, fn curr, acc ->
          key = elem(curr, 0)
          # Key is 1-4, like piano key 1, 2, 3 or 4
          index = elem(curr, 1)

          if key == nil do
            # Skip the nils. They are spaces with no musicc
            # We are lazy so we put an invisible square
            rect(acc, {0, 0},
              t: {0, 0},
              id: :rect_in,
              fill: :white
            )
          else
            # Move it 50 to the left, so we have space for current score
            x_offset = key * 150 - 50
            # Start off 200 down,
            y_offset = 200 - 200 * index

            rect(acc, {150, 200},
              t: {x_offset, y_offset},
              id: :rect_out,
              fill: :black
            )
            |> rect({150 - 8, 200 - 8},
              t: {x_offset + 4, y_offset + 4},
              id: :rect_in,
              fill: {10, 10, 180}
            )
          end
        end)
      end,
      translate: {100, 100},
      font: :roboto
    )
  end

  defp start_game(scene) do
    if !Map.get(scene, :started, false) do
      play_backing_track()
      # 120 BPM
      # There is 2 seconds of nothing (4 beats)
      # I move it 50s as sleight of hand, just improves the playing experience
      Process.send_after(self(), :start_loop, 1950)
      Process.send_after(Game, :start, 1950)

      :ok
    else
      {:error, :started}
    end
  end
end
