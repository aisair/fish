#! /usr/bin/env fish

if not count $argv > /dev/null
	echo 'you forgor the playlist link 💀'
	return 1
end

argparse "e/export" -- $argv
or return

set json (curl $argv | gsed -n 's/\s\{1,\}playlist: {/{/g; s/},/}/g; /{"playlistContent"/p')
set ids (echo $json | jq -r '.playlistContent' | tr , '\n')

echo "found $(count $ids) video ids, downloading...(this may take a while)"
for x in $ids
	set link "https://mediaspace.illinois.edu/media/t/$x"
	echo "downloading $link"
	yt-dlp -q --ignore-config $link
end

if set -q _flag_e
	echo $test | jq -r '.name' > pltitle.txt
end

echo "finished!~ 🐬"
