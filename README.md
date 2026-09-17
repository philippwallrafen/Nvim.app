# Nvim iTerm2 App

A small macOS launcher that opens **Neovim in iTerm2 from Spotlight**.

Press `⌘ Space`, search for `Nvim`, and hit Enter.

## Why?

Neovim installs as a terminal application on macOS, so there is no native `Nvim.app` to launch from Spotlight.

This project provides a minimal `.app` wrapper without adding a Neovim GUI.

## Requirements

- macOS
- [Neovim](https://neovim.io/)
- [iTerm2](https://iterm2.com/)

With Homebrew:

```sh
brew install neovim
brew install --cask iterm2
```

## Install

Download `Nvim.app.zip` from the latest GitHub Release, extract it, and move `Nvim.app` to `/Applications`.

The release is ad-hoc signed, not Apple-notarized. If macOS blocks the first launch, right-click `Nvim.app` and choose **Open**, or build it locally.

## Build

```sh
./build.sh
```

Output:

```text
dist/Nvim.app
dist/Nvim.app.zip
```

Build and install:

```sh
./install.sh
```

## How it works

The launcher starts iTerm2 if necessary and opens exactly one iTerm2 window running `nvim`. Quitting Neovim returns to the normal shell.

Neovim itself is not bundled.

## Disclaimer

This is an unofficial project and is not affiliated with or endorsed by Neovim or iTerm2.

The app icon is derived from the official Neovim mark:
https://neovim.io/logos/

## License

MIT
