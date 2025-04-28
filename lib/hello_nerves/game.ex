defmodule Game do
  # Should probably be behind a supervisor
  use GenServer

  # Callbacks

  @impl true
  def init(_) do
    IO.puts("INITIALIZE GAME")
    # Hard coding this is not ideal
    # We can always load this information after
    # But this is just a prototype
    keys = Mary.keys()
    {:ok, %{keys: keys, current_score: 0}}
  end

  def start_link(_) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__) |> IO.inspect()
  end

  # Make pressing a key as simple as callign this function
  def press_key(key) do
    GenServer.call(
      __MODULE__,
      {:press_key, key}
    )
  end

  @impl true
  # Key is 0-3 corresponding to the keys on the "piano"
  def handle_call({:press_key, key}, _from, state) do
    IO.puts("KEY PRESSED")
    # TODO: Add handling for last key
    [head | tail] = state.keys

    case key do
      0 -> Audio.play_0()
      1 -> Audio.play_1()
      2 -> Audio.play_2()
      3 -> Audio.play_3()
    end

    # No matter what we do, we want to remove the first key
    # The either got their point or it was skipped
    new_state =
      state |> Map.put(:keys, tail)

    # If key is correct increment score and remove the key from the keys
    if(head == key) do
      new_state = Map.put(new_state, :current_score, state.current_score + 1)
      {:reply, :correct, new_state}
    else
      {:reply, :incorrect, new_state}
    end
  end

  @impl true
  def terminate(reason, state) do
    IO.inspect(reason)
    IO.puts("TERMINATING--")
    :ok
  end
end
