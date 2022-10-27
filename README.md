# iex-history

[![asciicast](https://asciinema.org/a/gV4vsp7HTGblsNGBbJvGG75MJ.svg)](https://asciinema.org/a/gV4vsp7HTGblsNGBbJvGG75MJ)

## Installation

Hard requirements:

- erlang with history enabled [how to ?](https://til.hashrocket.com/posts/is9yfvhdnp-enable-history-in-iex-through-erlang-otp-20-)
- [tmux](https://github.com/tmux/tmux/) :warning: version 3 or more
- [fzf](https://github.com/junegunn/fzf)
- [bash](https://www.gnu.org/software/bash/)

To install, run the following to your terminal.

I put it in my $HOME but feel free to put it where you want
```shell
git clone https://github.com/mrdotb/iex-history ~/.iex-history
cd ~/.iex-history
MIX_ENV=prod mix escript.build 
```

Now we need to move the generated binary `iex-history` in your `$PATH` or add the `~/.iex-history` folder to your `$PATH`
```bash
mv iex-history ~/.local/bin/
```

Last step is to add the following line in your tmux config to call the script.
The tmux binding I use is `tmux prefix` `ctrl-r`.

```bash
bind C-r run-shell -b "bash ~/.iex-history/history.sh #{session_name} #{window_id} #D #{pane_current_command}"
```

Don't forget to reload tmux config

```bash
source-file ~/.tmux.conf
```
