# HelloNerves

**TODO: Add description**

## Targets

Nerves applications produce images for hardware targets based on the
`MIX_TARGET` environment variable. If `MIX_TARGET` is unset, `mix` builds an
image that runs on the host (e.g., your laptop). This is useful for executing
logic tests, running utilities, and debugging. Other targets are represented by
a short name like `rpi3` that maps to a Nerves system image for that platform.
All of this logic is in the generated `mix.exs` and may be customized. For more
information about targets see:

https://hexdocs.pm/nerves/supported-targets.html

## Getting Started

To start your Nerves app:

- `export MIX_TARGET=my_target` or prefix every command with
  `MIX_TARGET=my_target`. For example, `MIX_TARGET=rpi3`
- Install dependencies with `mix deps.get`
- Create firmware with `mix firmware`
- Burn to an SD card with `mix burn`

## Learn more

- Official docs: https://hexdocs.pm/nerves/getting-started.html
- Official website: https://nerves-project.org/
- Forum: https://elixirforum.com/c/nerves-forum
- Elixir Slack #nerves channel: https://elixir-slack.community/
- Elixir Discord #nerves channel: https://discord.gg/elixir
- Source: https://github.com/nerves-project/nerves

When building for RPI5 need this. For RPI4 should work the same (not 100% if cairo-fb though for the 4). For 3 and below you may need to change SCENIC_LOCAL and SCENIC_LOCAL_TARGET as well.

```
export MIX_TARGET=rpi5
export SCENIC_LOCAL_TARGET=cairo-fb # maybe mess with cairo-gtk
export SCENIC_LOCAL_GL=gles3
export NERVES_SYSTEM=rpi5
export MIX_ENV=target
```

Scenic docs say you need these for local as well

```
brew install gtk+3 cairo pkg-config
brew install glfw3 glew pkg-config
```
