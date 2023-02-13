#!/usr/bin/env fish

function ytdlwav --description "Downloads file using yt-dlp then converts to AAC using ffmpeg and afconvert"
    if type -q trash
        set TRASH_EXECUTABLE trash
    else
        set TRASH_EXECUTABLE rm
    end
    # set PICARD_EXECUTABLE "/Applications/MusicBrainz Picard.app/Contents/MacOS/picard-run"
    set PICARD_EXECUTABLE "open -a MusicBrainz\ Picard"

    if not count $argv > /dev/null
        echo 'you forgor the link 💀'
        return 1
    end

    argparse "h/help" "k/keep" -- $argv
    or begin
        set_color yellow
        echo "warn: argument parsing failed!"
        set_color normal
    end
    
    if set -q _flag_h
        builtin printf '%s\n' "ytdlwav Help" "Downloads file using yt-dlp then converts to WAV using ffmpeg" "Usage:" "ytdlwav [-hk] target_url" "-h or --help: prints this help sheet" "-k or --keep: keeps all intermediary files"
        return
    end
    
    set title (yt-dlp --print '%(title)s' $argv[1])
    set tmpdir (mktemp -d -t $title[1])

    builtin echo "downloading $title"
    set ytfile (yt-dlp -P $tmpdir --exec "builtin echo" -q -f ba -x --audio-format wav $argv[1])

    builtin echo "converting $title to AAC"
    # see apple-digital-masters.pdf (soundcheck was too quiet)
    set filename (string split -m1 -r -f1 "." $ytfile)
    afconvert $ytfile $filename.caf -d 0 -f caff
    afconvert $filename.caf -d aac -f m4af -u pgcm 2 -b 256000 -q 127 -s 2 $title.m4a
    
    if not set -q _flag_k
    	$TRASH_EXECUTABLE $tmpdir
    	builtin echo "deleted intermediary files ($(basename $ytfile) and $(basename $filename.caf))"
    end

    eval $PICARD_EXECUTABLE \"$PWD/$title.m4a\"
end

