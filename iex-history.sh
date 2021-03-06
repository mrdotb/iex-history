#!/usr/bin/env bash
# vim: noai:ts=4:sw=4:expandtab

# exit the script if any statement returns a non-true return value
set -e

# (session_name window_id pane_id pane_current_command)
# echo "$@"
session_name=${1:-$(tmux display -p '#{session_name}')}
window_id=${2:-$(tmux display -p '#{window_id}')}
pane_id=${3:-$(tmux display -p '#{pane_id}')}
pane_current_command=${4:-$(tmux display -p '#{pane_current_command}')}
current_pane=$(printf "%b:%b.%b\n" $session_name $window_id $pane_id)
# TODO find a smart way to handle the current line using capture-pane
# tmux capture-pane -J -S - -E - -b "iexsearch-$1" -t "$1"
# tmux split-window "tmux show-buffer -b iexsearch-$1 | grep ">" | more"

# if we are not runned from an iex aka "beam.smp" pan exit
if [ "$pane_current_command" != "beam.smp" ]; then
    exit
fi

id=$RANDOM
fifo="${TMPDIR:-/tmp}/iex-history-fifo-$id"
mkfifo -m o+w $fifo

tmux split-window "iex-history | fzf -s > $fifo"
tmux send-keys -t $current_pane -l "$(cat $fifo)"

# remove the fifo
rm -f $fifo
