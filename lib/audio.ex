defmodule Audio do
  def killall() do
    System.cmd("killall", [system_player()])
  end

  def play(file_name) do
    spawn(fn ->
      static_directory_path =
        Path.join(:code.priv_dir(:hello_nerves), "audio")

      full_path =
        Path.join(static_directory_path, file_name)

      System.cmd(system_player(), build_cli_params(full_path))

      Audio.play(file_name)
    end)
  end

  defp system_player() do
    if Application.get_env(:hello_nerves, :on_host) do
      "afplay"
    else
      "aplay"
    end
  end

  defp build_cli_params(path) do
    if Application.get_env(:hello_nerves, :on_host) do
      [path]
    else
      ["-f", path]
    end
  end
end
