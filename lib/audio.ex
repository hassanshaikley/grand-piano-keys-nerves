defmodule Audio do
  def killall() do
    # Spawn because we want to be ok if it crashes ?
    spawn(fn ->
      nil
      # System.cmd("killall", [system_player()])
    end)
  end

  # c d e g
  def play_1(), do: play("c4.wav")
  def play_2(), do: play("d4.wav")
  def play_3(), do: play("e4.wav")
  def play_4(), do: play("g4.wav")

  def play(file_name) do
    # spawn(fn ->
    #   static_directory_path =
    #     Path.join(:code.priv_dir(:hello_nerves), "audio")

    #   full_path =
    #     Path.join(static_directory_path, file_name)

    #   System.cmd(system_player(), build_cli_params(full_path))
    # end)
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
      ["-f", "S16_LE", "-vv", path]
    end
  end

  # def get_system_audio_player_pid() do
  #   System.cmd("pgrep", ["-x", system_player()])
  #   |> then(fn {pid, 0} ->
  #     String.trim_trailing(pid, "\n")
  #   end)
  # end

  # Ma
  # defp set_audio_output_to_usb do
  #   try do
  #     # System.cmd("amixer", ["cset", "numid=3", "1"], stderr_to_stdout: true)
  #     :os.cmd('amixer cset numid=3 1')
  #   rescue
  #     e in ErlangError -> "Error!"
  #   end
  # end
end

# Pause
# kill -TSTP 76336

# Play
# kill -CONT  76336
