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

    # show the version of scenic and the glfw driver
    scenic_ver = Application.spec(:scenic, :vsn) |> to_string()
    driver_ver = Application.spec(:scenic_driver_local, :vsn) |> to_string()

    info = "scenic: v#{scenic_ver}\nscenic_driver_local: v#{driver_ver}"

    scene = push_graph(scene, main_page())

    scene = Map.put(scene, :iteration, 0)
    {:ok, scene}
  end

  def terminate(_reason, _) do
    Audio.killall()
  end

  def handle_info(:loop, state) do
    iteration = Map.get(state, :iteration)

    Process.send_after(self(), :loop, 100)

    push_graph(state, game_page(iteration))

    state = Map.put(state, :iteration, iteration + 5)

    {:noreply, state}
  end

  # x_offset = 1..4
  # 800 wide screen, so 200 blocks
  # 150 * 4 + 20 * 5 = 100 + 600 + 50 on aech side
  # 20 px 150 px 20 px 150 px 20 px 150 px 20px 150 px 20px
  def my_rect(graph, x_offset, y_offset) do
    rect(graph, {150, 200},
      t: {70 + x_offset * 170, 10 + y_offset},
      id: :rect_in,
      fill: :white
    )
  end

  def main_page() do
    Graph.build(font: :roboto, font_size: @text_size)
    |> rect({200, 50}, t: {10, 10}, id: :rect_in, fill: :blue, input: [:cursor_button])
    |> text("Start Game", t: {110, 45}, text_align: :center)
  end

  def game_page(iteration) do
    Graph.build(font: :roboto, font_size: @text_size)
    |> my_rect(0, iteration)
    |> my_rect(1, iteration)
    |> my_rect(2, iteration)
    |> my_rect(3, iteration)
  end

  def handle_input(event, _context, scene) do
    # Logger.info("Received event: #{inspect(event)}")
    # IO.puts("Input received")

    Process.send_after(self(), :loop, 250)

    play_backing_track()

    scene = push_graph(scene, game_page(0))

    {:noreply, scene}
  end

  def play_backing_track() do
    file_name = "mary_btrack.wav"

    Audio.play(file_name)
  end
end
