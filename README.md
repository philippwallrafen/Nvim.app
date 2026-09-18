<p align="center">
  <img src="docs/images/nvim-app.png" alt="Nvim.app in the macOS Applications folder" width="640">
</p>

# Nvim iTerm2 App

A small macOS launcher that opens **Neovim from Spotlight or Finder**. It uses iTerm2 when available and falls back to Terminal.app.

Press `⌘ Space`, search for `Nvim`, and hit Enter.

When you quit Neovim with `:q`, the terminal session ends.

## Installation

Recommended: build and install locally.

```sh
brew install neovim

# Optional: Nvim uses Terminal.app when iTerm2 is not installed.
brew install --cask iterm2

git clone https://github.com/philippwallrafen/nvim-iterm2-app.git
cd nvim-iterm2-app
./nvim-app.sh install
```

The script builds `Nvim.app`, signs it locally, installs it to `/Applications`, and registers it with macOS.

Then launch it with:

```text
⌘ Space → Nvim → Enter
```

macOS may ask for permission to let Nvim control iTerm2 or Terminal on first launch. Allow it.

## Open files from Finder

After installation, Nvim is registered as an editor for text files.

In Finder, right-click a text file and choose:

```text
Open With → Nvim
```

The file opens in Neovim inside iTerm2 when it is installed, otherwise in Terminal.app.

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

The build only requires macOS. iTerm2 is a runtime option and is not required to construct the app bundle.

## Prebuilt release

You can also download `Nvim.app.zip` from the latest GitHub Release, extract it, and move `Nvim.app` to `/Applications`.

The prebuilt release is ad-hoc signed, not Apple-notarized. macOS may require **right-click → Open** on first launch.

## Requirements

- macOS
- [Neovim](https://neovim.io/)
- [iTerm2](https://iterm2.com/) (optional; Terminal.app is used otherwise)

## How it works

`Nvim.app` is a small AppleScript launcher. It builds the `nvim` command, then selects a terminal backend at runtime.

If iTerm2 is installed, Nvim uses it. Otherwise it uses the built-in Terminal.app. The iTerm2-specific AppleScript is bundled as a runtime resource, so iTerm2 is not needed when building `Nvim.app`.

When files are opened through Finder or `open -a Nvim`, their paths are passed to Neovim.

Neovim itself is not bundled.

## Disclaimer

This is an unofficial project and is not affiliated with or endorsed by Neovim or iTerm2.

The app icon is derived from the official [Neovim logo assets](https://github.com/neovim/neovim.github.io/tree/master/static/logos).

## License

MIT
