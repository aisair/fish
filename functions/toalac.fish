#!/usr/bin/env fish
function toalac -d "converts file/directory of audio files to ALAC"
    if not count $argv > /dev/null
        echo 'you forgor the file/directory 💀'
        echo 'toalac -h for help sheet ❓'
        return 1
    end
    argparse "h/help" "f/folder=" "d/delete" "p/preserve" -- $argv
    or return

    set PICARD_EXECUTABLE "open -a MusicBrainz\ Picard"
    if type -q trash
        set TRASH_EXECUTABLE 'trash -F'
    else
        set TRASH_EXECUTABLE rm
    end

    if set -q _flag_h
        printf '%s\n' 'toalac Help' 'Attempts to convert audio files to ALAC' 'Usage:' 'toalac [-dh] [-f path_to_destination folder] path_to_file_or_directory' '-h or --help: prints this help sheet' '-f [folder_name] or --folder [folder_name]: put ALAC files into specified folder' '-d or --delete: delete original files' '-p or --preserve: copy metadata to ALAC file'
        return
    end

    if test -d $argv[1]
        echo 'Input is a directory 📁'
        set FOLDER $argv[1]
        for x in $argv[1]/*
            if test -f $x
                set -a FILE $x
    end
    end
    else if test -f $argv[1]
        echo 'Input is a file 📄'
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

    set -e mflag
    if not set -q _flag_p
        set mflag "-map_metadata" "-1"
        echo "clearing metadata from files"
    end

    echo 'converting files to ALAC, this may take a bit'
    for x in (seq (count $FILE)) # i have no idea how to do it better tbh
        ffmpeg -q -i "$FILE[$x]" -vn $mflag[1] $mflag[2] -c:a alac $FOLDER/(string split -r -m1 -f1 '.' (basename $FILE[$x])).m4a
    end

    if set -q _flag_d
        eval $TRASH_EXECUTABLE \"$FILE\"
        echo 'deleted original file(s)'
    end 

    if test (count $FILE) -gt 1
        eval $PICARD_EXECUTABLE \"$FOLDER\"
    else
        eval $PICARD_EXECUTABLE \"$FOLDER/(string split -r -m1 -f1 '.' (basename $FILE)).m4a\"
    end
end
