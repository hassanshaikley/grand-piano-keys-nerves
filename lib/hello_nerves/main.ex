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
    # Process.send_after(self(), :loop, 1000)
    setup()
    IO.puts("Hello")
    Logger.info("Hello")
    {:ok, elements}
  end

  def setup do
    if Application.get_env(:hello_nerves, :on_host) do
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

  # @impl true
  def handle_info(:loop, state) do
    # Process.send_after(self(), :loop, 1000)

    # {:ok, gpio} = Circuits.GPIO.open(@button_one, :input)

    # thing = Circuits.GPIO.read(gpio)

    # IO.puts("Looping and thing is #{inspect(thing)}")

    {:noreply, state}
  end

  def handle_info({:circuits_gpio, @button_one, _stamp, falling}, state) do
    IO.puts("BUTTOTN ONE EVENT #{falling}")

    {:noreply, state}
  end

  def handle_info({:circuits_gpio, @button_two, _stamp, falling}, state) do
    IO.puts("BUTTOTN two EVENT #{falling}")

    {:noreply, state}
  end

  def handle_info({:circuits_gpio, @button_three, _stamp, falling}, state) do
    IO.puts("BUTTOTN three EVENT #{falling}")

    {:noreply, state}
  end

  def handle_info({:circuits_gpio, @button_four, _stamp, falling}, state) do
    IO.puts("BUTTOTN four EVENT #{falling}")

    {:noreply, state}
  end

  def handle_info({:circuits_gpio, pin, _stamp, falling}, state) do
    IO.puts("Pin: #{pin} - falling:#{falling}")
    {:noreply, state}
  end
end
