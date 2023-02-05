#! /usr/bin/env fish

mkdir metadatad
for x in *.m4v
	set data (string match -r 'Module ([\d\.]+) - (.+) \[' $x)
	ffmpeg -i $x -c copy -map_metadata 0 -metadata episode_sort=$data[2] -metadata title=$data[3] -metadata season_number=1 -metadata show="MATH 257 Lecture Videos" "./metadatad/$x"
end
