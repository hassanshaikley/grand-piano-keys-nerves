defmodule HelloNerves do
  @moduledoc """
  Documentation for `HelloNerves`.
  """

  @doc """
  Hello world.

  ## Examples

      iex> HelloNerves.hello()
      :world

  """
  def hello do
    # {:ok, gpio} = Circuits.GPIO.open("GPIO12", :output)

    :world
  end

  def loop do
    IO.puts("Loop")
  end
end
