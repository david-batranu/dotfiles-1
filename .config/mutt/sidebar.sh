#!/bin/sh

## Set sidebar options only if sidebar is builtin.
if [ -n "$(man muttrc | grep sidebar)" ]; then
	cat <<'EOF'
set sidebar_visible = yes
set sidebar_width = 24
set sidebar_sort_method = alpha
set sidebar_divider_char=' '
set sidebar_short_path = yes
set sidebar_format = "%B%?F? [%F]?%* %?N?%N/?%S"
set sidebar_folder_indent = yes

## Color of folders with new mail
color sidebar_new $my_new $my_bg

## Ctrl-n, Ctrl-p to select next, previous folder.
## Ctrl-o to open selected folder
bind index,pager \CP sidebar-prev
bind index,pager \CN sidebar-next
bind index,pager \CO sidebar-open

## Toggle sidebar visibility. Screen might get messed up, hence the refresh.
macro index b '<enter-command>toggle sidebar_visible<enter><refresh>'
macro pager b '<enter-command>toggle sidebar_visible<enter><redraw-screen>'
EOF
fi