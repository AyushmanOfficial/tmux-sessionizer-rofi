# tmux-sessionizer (Rofi Edition)

A Rofi-powered twist on [ThePrimeagen’s tmux-sessionizer](https://github.com/ThePrimeagen/tmux-sessionizer).  
Quickly jump between dev projects using tmux + rofi.

## What It Does

- Lists your project folders
- Shows current tmux sessions
- Lets you pick one via Rofi
- If the session exists → attaches  
- Else → spawns a new one in that dir

## Requirements

- [`tmux`](https://github.com/tmux/tmux)
- [`rofi`](https://github.com/davatorium/rofi)
- A terminal like [`alacritty`](https://github.com/alacritty/alacritty) (edit to use yours)

## Install

```bash
git clone https://github.com/AyushmanOfficial/tmux-sessionizer-rofi
cd tmux-sessionizer-rofi
mkdir -p ~/.config/rofi/tmux
cp launch.sh ~/.config/rofi/tmux/launch.sh
chmod +x ~/.config/rofi/tmux/launch.sh
cp style.rasi ~/.config/rofi/tmux/style.rasi
```

Make sure it’s executable and in your `$PATH`.

## Usage

You should just bind it to a shortcut in your TWM/DE

- i3
```bash
bindsym $mod+d exec --no-startup-id ~/.config/rofi/tmux/launch.sh
```

- Hyprland
```bash
bind = $mod, N, exec, ~/.config/rofi/tmux/launch.sh
```


## Contributing

PRs welcome—keep it neat, keep it minimal.

## Credits

- [ThePrimeagen/tmux-sessionizer](https://github.com/ThePrimeagen/tmux-sessionizer)
- [kickstart.nvim by TJ DeVries](https://github.com/nvim-lua/kickstart.nvim)
