defmodule Game do
  # Should probably be behind a supervisor
  use GenServer

  # Callbacks

  require Logger

  @time_between_notes 500
  @allowed_ms_before_note 0

  @impl true
  def init(_) do
    # Hard coding this is not ideal
    # We can always load this information after
    # But this is just a prototype
    # played_indexes is just to keep track of whether a note was guessed on, really can be a list
    keys = Mary.keys()
    Scenic.PubSub.register(:debug)
    {:ok, %{keys: keys, current_score: 0, started_at: nil, played_indexes: %{}}}
  end

  def start_link(_) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  # Make pressing a key as simple as callign this function
  def press_key(key) do
    GenServer.call(
      __MODULE__,
      {:press_key, key}
    )
  end

  def get_score() do
    GenServer.call(
      __MODULE__,
      :get_score
    )
  end

  def reset() do
    GenServer.call(
      __MODULE__,
      :reset
    )
  end

  # This function is used to know which note we are currently on
  # Based off the time from when it starts we know the current note
  # Technically this is not necessary, as long as we know the start time we can figure out
  # Which note we are on
  @impl true
  def handle_info(:start, state) do
    # BPM Makes it a note every half second

    state = Map.put(state, :started_at, DateTime.utc_now())
    {:noreply, state}
  end

  def handle_call(:reset, _from, state) do
    {:reply, :ok, Map.put(state, :current_score, 0) |> Map.put(:played_indexes, %{})}
  end

  def handle_call(:get_score, _from, state) do
    {:reply, state.current_score, state}
  end

  @impl true
  # Key is 1-4 corresponding to the keys on the "piano"
  # Returns current score (0 when invalid, not ideal but not a big deal)
  def handle_call({:press_key, key}, _from, state) do
    # Make the sound ?
    case key do
      1 -> Audio.play_1()
      2 -> Audio.play_2()
      3 -> Audio.play_3()
      4 -> Audio.play_4()
    end

    # TODO: Add handling for last key
    with false <- is_nil(Map.get(state, :started_at)),
         current_index when is_integer(current_index) <- get_current_index(state),
         {:over, false} <- {:over, game_over?(current_index)},
         current_key when not is_nil(current_key) <- Enum.at(state.keys, current_index) do
      # Just keep track of whether we already tried this note
      new_state = put_in(state, [:played_indexes, current_index], true)

      # Key is not zero indexed
      # TODO: Just make them the same
      if(current_key == key - 1) do
        new_state = Map.put(new_state, :current_score, state.current_score + 1)

        {:reply, new_state.current_score, new_state}
      else
        # We will remove a point when you get it wrong

        new_state = Map.put(state, :current_score, state.current_score - 1)

        {:reply, state.current_score, new_state}
      end
    else
      {:over, true} ->
        # Basically a noop
        Scenic.PubSub.publish(:debug, "Over")

        {:reply, state.current_score, state}

      nil ->
        Scenic.PubSub.publish(:debug, "nil")

        # We will remove a point when you plahy when theres no note
        new_state = Map.put(state, :current_score, state.current_score - 1)

        {:reply, new_state.current_score, new_state}

      true ->
        Scenic.PubSub.publish(:debug, "true")

        {:reply, state.current_score, state}

      {:error, :already_played} ->
        Scenic.PubSub.publish(:debug, "already played")

        # We will remove a point when you double play
        new_state = Map.put(state, :current_score, state.current_score - 1)

        {:reply, new_state.current_score, new_state}
    end
  end

  @impl true
  def terminate(reason, _state) do
    Logger.info("Game Terminated #{inspect(reason)}")
    :ok
  end

  defp get_current_index(state) do
    millsecond_diff_from_start =
      DateTime.diff(DateTime.utc_now(), state.started_at, :millisecond)

    # Need the math max becuase right when we start we will get a negative number (first 50 ms)
    current_index = div(millsecond_diff_from_start, 500)

    already_played = get_in(state, [:played_indexes, current_index])

    if already_played do
      {:error, :already_played}
    else
      current_index
    end
  end

  # This is bad. It is hard coded
  # Better to use the length of Mary.keys()
  defp game_over?(current_index) when current_index <= 61 do
    false
  end

  defp game_over?(_current_index) do
    true
  end
end
