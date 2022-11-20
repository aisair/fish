function toalac --description 'Attempts to convert audio files to ALAC'
    if not count $argv > /dev/null
        echo 'you forgor the file/directory 💀'
	return 1
    end
    argparse "h/help" "f/folder=" "d/delete" -- $argv
    or return
    set PICARD_EXECUTABLE "open -a MusicBrainz\ Picard"
    if type -q trash
        set TRASH_EXECUTABLE 'trash -F'
    else
        set TRASH_EXECUTABLE rm
    end

    if set -q _flag_h
        echo 'toalac Help'
	echo 'Attempts to convert audio files to ALAC'
        echo 'Usage:'
	echo 'toalac [-h] path_to_file_or_directory'
	echo ''
	echo '-h or --help: prints this help sheet'
	echo '-f [folder_name] or --folder [folder_name]: put ALAC files into specified folder'
	echo '-d or --delete: delete original files'
	return
    end
    
    if test -d $argv[1]
        echo 'Input is a directory'
	set FOLDER $argv[1]
	for x in $argv[1]/*
	    if test -f $x
	        set -a FILE $x
	    end
	end
    else if test -f $argv[1]
        echo 'Input is a file'
	set FOLDER (dirname $argv[1])
	set -a FILE $argv[1]
    else
        echo 'Input is ???? 🤔'
	return 1
    end
    
    if set -q _flag_f
	mkdir -p $FOLDER/$_flag_f/
	set FOLDER $FOLDER/$_flag_f
	echo "putting converted files into (basename $FOLDER)"
    end

    for x in (seq (count $FILE)) # i have no idea how to do it better tbh
        ffmpeg -hide_banner -loglevel error -i "$FILE[$x]" -vn -map_metadata -1 -c:a alac $FOLDER/(string split -r -m1 -f1 '.' (basename $FILE[$x])).m4a
    end
    echo 'converted files to ALAC'
    
    if test (count $FILE) -gt 1
        eval $PICARD_EXECUTABLE \"$FOLDER\"
    else
        eval $PICARD_EXECUTABLE \"$FOLDER/(string split -r -m1 -f1 '.' (basename $FILE)).m4a\"
    end

    if set -q _flag_d
        eval $TRASH_EXECUTABLE \"$FILE\"
	echo "deleted original file(s)"
    end 
end
