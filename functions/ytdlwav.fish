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
        echo "ytdl-ffmpeg-wav Help"
	echo "Downloads file using yt-dlp then converts to WAV using ffmpeg"
	echo "Usage:"
	echo "ytdl-ffmpeg-wav [-hk] target_url"
	echo -e \n"-h or --help: prints this help sheet"
	echo "-k or --keep: keeps all intermediary files"
	return
    end

    set SONGTITLE (yt-dlp --print '%(title)s' $argv[1])
    set SONGUUID (uuidgen)

    echo "downloading $SONGTITLE"
    set ytFILE (yt-dlp -o "$SONGUUID.%(ext)s" --exec echo -q -f ba -x $argv[1])
    echo "downloaded $SONGTITLE to $ytFILE"
    
    echo "converting $(basename $ytFILE) to WAV"
    ffmpeg -loglevel error -i $ytFILE $SONGUUID.wav
    echo "converted $(basename $ytFILE) to $SONGUUID.wav"

    echo "converting $SONGUUID.wav to AAC"
    # see apple-digital-masters.pdf (soundcheck was too quiet)
    afconvert $SONGUUID.wav $SONGUUID.caf -d 0 -f caff
    afconvert $SONGUUID.caf -d aac -f m4af -u pgcm 2 -b 256000 -q 127 -s 2 $SONGTITLE.m4a
    echo "converted $SONGUUID.wav to $SONGTITLE.m4a"
    
    if not set -q _flag_k
    	$TRASH_EXECUTABLE $ytFILE $SONGUUID.wav $SONGUUID.caf
    	echo "deleted intermediary files $(basename $ytFILE), $SONGUUID.wav, and $SONGUUID.caf"
    end

    eval $PICARD_EXECUTABLE \"$PWD/$SONGTITLE.m4a\"
end

