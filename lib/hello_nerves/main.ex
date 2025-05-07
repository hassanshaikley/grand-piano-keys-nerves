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

  def handle_info({:circuits_gpio, @button_one, _stamp, 1}, state) do
    IO.puts("BUTTOTN one EVENT")

    new_score = Game.press_key(1)

    Scenic.PubSub.publish(:breadboard_button_input, new_score)

    {:noreply, state}
  end

  def handle_info({:circuits_gpio, @button_two, _stamp, 1}, state) do
    IO.puts("BUTTOTN two EVENT")

    new_score = Game.press_key(2)

    Scenic.PubSub.publish(:breadboard_button_input, new_score)

    {:noreply, state}
  end

  def handle_info({:circuits_gpio, @button_three, _stamp, 1}, state) do
    IO.puts("BUTTOTN three EVENT")

    new_score = Game.press_key(3)

    Scenic.PubSub.publish(:breadboard_button_input, new_score)

    {:noreply, state}
  end

  def handle_info({:circuits_gpio, @button_four, _stamp, 1}, state) do
    IO.puts("BUTTOTN four EVENT")

    new_score = Game.press_key(4)

    Scenic.PubSub.publish(:breadboard_button_input, new_score)

    {:noreply, state}
  end

  def handle_info({:circuits_gpio, pin, _stamp, falling}, state) do
    IO.puts("Pin: #{pin} - falling:#{falling}")
    {:noreply, state}
  end
end
