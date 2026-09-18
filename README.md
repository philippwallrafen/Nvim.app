<p align="center">
  <img src="docs/images/nvim-app.png" alt="Nvim.app in the macOS Applications folder" width="640">
</p>

# Nvim.app

A macOS app wrapper for Neovim.

Launch Neovim from Spotlight, Finder, or the command line using Terminal.app, Ghostty, iTerm2, Warp, or Alacritty.

## Installation

```sh
brew install neovim

git clone https://github.com/philippwallrafen/Nvim.app.git
cd Nvim.app
./nvim-app.sh install
```

Then launch it with:

```text
⌘ Space → Nvim → Enter
```

macOS may ask for permission to let Nvim control your terminal on first launch.

## Terminal selection

Supported terminals:

- Terminal.app
- Ghostty
- iTerm2
- Warp
- Alacritty

No third-party terminal is required.

If no preference is saved:

- with no supported third-party terminal installed, Nvim.app uses Terminal.app
- with exactly one installed, Nvim.app uses it automatically
- with multiple installed, Nvim.app asks which one to use and remembers the choice

Show the current preference:

```sh
./nvim-app.sh terminal
```

Choose again:

```sh
./nvim-app.sh terminal choose
```

Set one explicitly:

```sh
./nvim-app.sh terminal ghostty
./nvim-app.sh terminal iterm2
./nvim-app.sh terminal warp
./nvim-app.sh terminal alacritty
./nvim-app.sh terminal terminal
```

Reset the saved preference so Nvim.app selects again:

```sh
./nvim-app.sh terminal auto
```

The preference is stored in macOS defaults under:

```text
io.github.philippwallrafen.nvim-app
```

If you installed only the prebuilt app, you can change it directly:

```sh
defaults write io.github.philippwallrafen.nvim-app terminal ghostty
defaults delete io.github.philippwallrafen.nvim-app terminal
```

## Open files from Finder

After installation, Nvim is registered as an editor for text files.

In Finder, right-click a text file and choose:

```text
Open With → Nvim
```

The file is passed to Neovim in the selected terminal.

<!--
Screenshot placeholder:
Add docs/images/nvim-open-with.png showing Nvim.app in Finder's Open With context menu.

<p align="center">
  <img src="docs/images/nvim-open-with.png" alt="Nvim.app in the Finder Open With context menu" width="640">
</p>
-->

You can also open a file from the command line:

```sh
open -a Nvim README.md
```

To make Nvim the default editor for a file type, select a file in Finder, choose **Get Info**, select **Nvim** under **Open with**, then click **Change All**.

## Other commands

```sh
./nvim-app.sh build
./nvim-app.sh package
```

- `build` creates `dist/Nvim.app`
- `package` creates `dist/Nvim.app.zip`

The build only requires macOS. Third-party terminals are runtime integrations and are not required to build the app.

## Prebuilt release

You can also download `Nvim.app.zip` from the latest GitHub Release, extract it, and move `Nvim.app` to `/Applications`.

The prebuilt release is ad-hoc signed, not Apple-notarized. macOS may require **right-click → Open** on first launch.

## Requirements

- macOS
- [Neovim](https://neovim.io/)

Optional terminal integrations:

- [Ghostty](https://ghostty.org/)
- [iTerm2](https://iterm2.com/)
- [Warp](https://www.warp.dev/)
- [Alacritty](https://alacritty.org/)

## How it works

`Nvim.app` is a small AppleScript wrapper around Neovim. Finder and Spotlight launch the app, which passes the Neovim command to a small runtime terminal selector.

Terminal-specific integration is loaded only at runtime. Neovim itself is not bundled.

## Disclaimer

This is an unofficial project and is not affiliated with or endorsed by Neovim or any supported terminal project.

The app icon is derived from the official [Neovim logo assets](https://github.com/neovim/neovim.github.io/tree/master/static/logos).

## License

MIT
