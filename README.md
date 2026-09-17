# Nvim iTerm2 App

A small macOS launcher that opens **Neovim in iTerm2 from Spotlight**.

Press `⌘ Space`, search for `Nvim`, and hit Enter.

## Why?

Neovim installs as a terminal application on macOS, so there is no native `Nvim.app` to launch from Spotlight.

This project provides a minimal `.app` wrapper without replacing Neovim or adding a GUI frontend.

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

If macOS requires the app to be re-signed:

```sh
codesign --force --deep --sign - /Applications/Nvim.app
```

## Build

```sh
./build.sh
```

Output:

```text
dist/Nvim.app
dist/Nvim.app.zip
```

To build and install directly:

```sh
./install.sh
```

## How it works

The launcher is a small AppleScript app. It starts iTerm2 if necessary and opens exactly one iTerm2 window running `nvim`.

Neovim itself is not bundled.
