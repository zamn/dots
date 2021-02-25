#!/usr/bin/bash

workspace_dest=$1

current_workspace=$(i3-msg -t get_workspaces | jq -r '.[] | select(.focused==true).name')

if [[ "$current_workspace" = "$workspace_dest" ]]
then
    i3-msg -t run_command focus next 2>&1>/dev/null
else
    i3-msg -t run_command workspace "\"$workspace_dest\"" 2>&1>/dev/null
fi
