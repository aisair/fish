#! /usr/bin/env fish
# this was an older version of the kpdl that took a parsed input file with the video ids
# kpdl.fish can parse the given playlist link and also download them, making this obsolete

if not count $argv > /dev/null
	echo 'you forgor the playlist file 💀'
	return 1
end

set ids (cat $argv)
echo "downloading $(count $ids) files"
echo 'starting downloads... (this may take a while)'
for x in $ids
	set link "https://mediaspace.illinois.edu/media/t/$x"
	echo "downloading $link"
	yt-dlp -q --ignore-config $link
end

echo "hopefully it downloaded lmao"
