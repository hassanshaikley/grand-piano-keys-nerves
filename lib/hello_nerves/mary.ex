defmodule Mary do
  @moduledoc """
  Mary had a littel lamb song data
  """

  def keys do
    # Wonder if third row needs 1 more nil?
    [2, 1, 0, 1, 2, 2, 2, nil, 1, 1, 1, nil] ++
      [2, 3, 3, nil] ++
      [2, 1, 0, 1, 2, 2, 2, 2, 1, 1, 2, 1, 0, nil, nil] ++
      [2, 1, 0, 1, 2, 2, 2, nil, 1, 1, 1, nil] ++
      [2, 3, 3, nil] ++
      [2, 1, 0, 1, 2, 2, 2, 2, 1, 1, 2, 1, 0]

    # Lazy way of adding one, shoudl probably standardize
    # TODO: Fix
  end
end
