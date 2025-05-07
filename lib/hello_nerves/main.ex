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

    # Process.send_after(self(), :test, 1000)
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

  # def handle_info(:test, state) do
  #   Logger.info("BEFORE")
  #   new_score = Game.press_key(1)
  #   Logger.info("- #{inspect(new_score)}")

  #   Scenic.PubSub.publish(:breadboard_button_input, new_score) |> IO.inspect()

  #   {:noreply, state}
  # end

  def handle_info({:circuits_gpio, @button_one, _stamp, _}, state) do
    Logger.info("BUTTOTN one EVENT")

    new_score = Game.press_key(1)

    Scenic.PubSub.publish(:breadboard_button_input, new_score)

    {:noreply, state}
  end

  def handle_info({:circuits_gpio, @button_two, _stamp, _}, state) do
    new_score = Game.press_key(2)

    Scenic.PubSub.publish(:breadboard_button_input, new_score)

    {:noreply, state}
  end

  def handle_info({:circuits_gpio, @button_three, _stamp, _}, state) do
    new_score = Game.press_key(3)

    Scenic.PubSub.publish(:breadboard_button_input, new_score)

    {:noreply, state}
  end

  def handle_info({:circuits_gpio, @button_four, _stamp, _}, state) do
    new_score = Game.press_key(4)

    Scenic.PubSub.publish(:breadboard_button_input, new_score)

    {:noreply, state}
  end

  def handle_info({:circuits_gpio, pin, _stamp, falling}, state) do
    # Logger.info("Pin: #{pin} - falling:#{falling}")

    {:noreply, state}
  end
end
