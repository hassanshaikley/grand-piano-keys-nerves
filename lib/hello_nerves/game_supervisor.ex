defmodule GameSupervisor do
  use Supervisor

  def start_link(opts), do: Supervisor.start_link(__MODULE__, opts, name: __MODULE__)

  def init(opts) do
    children = [
      {Game, opts}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
