defmodule Main do
  use GenServer

  # Callbacks

  @button_one "GPIO17"

  @button_two "GPIO27"

  @button_three "GPIO22"

  @button_four "GPIO26"

  require Logger

  def start_link(default) do
    GenServer.start_link(__MODULE__, default)
  end

  # @impl true
  def init(elements) do
    setup()

    # Scenic.PubSub.register(:debug)

    Process.send_after(self(), :test, 1000)
    # Process.send_after(self(), :test, 2000)

    Logger.info("Hello")
    {:ok, elements}
  end

  def setup do
    Scenic.PubSub.register(:breadboard_button_input)

    if Application.get_env(:hello_nerves, :on_host) do
      :noop
    else
      # RPI Setup

      {:ok, gpio} = Circuits.GPIO.open(@button_one, :input)

      Circuits.GPIO.set_interrupts(gpio, :rising)

      {:ok, gpio} = Circuits.GPIO.open(@button_two, :input)

      Circuits.GPIO.set_interrupts(gpio, :rising)

      {:ok, gpio} = Circuits.GPIO.open(@button_three, :input)

      Circuits.GPIO.set_interrupts(gpio, :rising)

      {:ok, gpio} = Circuits.GPIO.open(@button_four, :input)

      Circuits.GPIO.set_interrupts(gpio, :rising)
    end
  end

  def handle_info(:test, state) do
    resp = System.shell("aplay -l ", stderr_to_stdout: true)

    # Scenic.PubSub.publish(:debug, "hoo: #{inspect(resp)}")

    Audio.play_1()

    {:noreply, state}
  end

  def handle_info({:circuits_gpio, @button_one, _stamp, _}, state) do
    Logger.info("BUTTOTN one EVENT")

    new_score = Game.press_key(1)
    log(new_score)

    Scenic.PubSub.publish(:breadboard_button_input, new_score)

    {:noreply, state}
  end

  def handle_info({:circuits_gpio, @button_two, _stamp, _}, state) do
    new_score = Game.press_key(2)
    log(new_score)

    Scenic.PubSub.publish(:breadboard_button_input, new_score)

    {:noreply, state}
  end

  def handle_info({:circuits_gpio, @button_three, _stamp, _}, state) do
    new_score = Game.press_key(3)
    log(new_score)

    Scenic.PubSub.publish(:breadboard_button_input, new_score)

    {:noreply, state}
  end

  def handle_info({:circuits_gpio, @button_four, _stamp, _}, state) do
    new_score = Game.press_key(4)
    log(new_score)

    Scenic.PubSub.publish(:breadboard_button_input, new_score)

    {:noreply, state}
  end

  def handle_info({:circuits_gpio, pin, _stamp, falling}, state) do
    # Logger.info("Pin: #{pin} - falling:#{falling}")

    {:noreply, state}
  end

  def handle_info(:clear_dbg, state) do
    # Scenic.PubSub.publish(:debug, "--}")

    {:noreply, state}
  end

  def log(new_score) do
    # Scenic.PubSub.publish(:debug, "new score: #{inspect(new_score)}")

    Process.send_after(self(), :clear_dbg)
  end
end
