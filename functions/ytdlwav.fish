function ytdlwav --description "Downloads file or playlist using yt-dlp then converts to AAC using ffmpeg and afconvert"
    if type -q trash
        set TRASH_EXECUTABLE trash
    else
        set TRASH_EXECUTABLE rm
    end
    
    # set PICARD_EXECUTABLE "/Applications/MusicBrainz Picard.app/Contents/MacOS/picard-run"
    set PICARD_EXECUTABLE "open -a MusicBrainz\ Picard"

    argparse "d/disable-picard" "h/help" "k/keep" "w/wav" -- $argv
    or begin
        set_color yellow
        builtin echo "warn: argument parsing failed! ⚠️"
        set_color normal
        return 1
    end
    
    if not count $argv > /dev/null
        builtin echo 'you forgor the link 💀'
        return 1
    end

    if set -q _flag_h
        builtin printf '%s\n' "ytdlwav Help" "Downloads file or playlist using yt-dlp then converts to AAC using ffmpeg and afconvert" "Usage:" "ytdlwav [-hk] target_url" "-d or --disable-picard: disables opening Picard after files download" "-h or --help: prints this help sheet" "-k or --keep: keeps all intermediary files" "-w or --wav: converts to WAVE instead of AAC (implies -d, WAVE not really compatible with picard)"
        return
    end
    
    if string match -e "playlist" $argv[1] > /dev/null
        set comb (yt-dlp --ignore-config --flat-playlist --print playlist_title --print title $argv[1])[2..]
        set title (string join "/" $comb | string split "/$comb[2]/")
        set cname $comb[2]
        set -e comb
        mkdir -p $cname
        set folder $PWD/$cname
    else
        set title (yt-dlp --ignore-config --print '%(title)s' $argv[1])
        set cname $title
        set folder $PWD
    end
    
    set tmpdir (mktemp -d -t $cname)

    builtin echo "downloading $cname"
    set ytfile (yt-dlp --ignore-config --paths $tmpdir --exec "builtin echo" --quiet --format bestaudio --extract-audio --audio-format wav $argv[1])

    if not set -q _flag_w
        builtin echo "converting $cname to AAC"
        for i in (seq (count $ytfile))
            set filename (string split -m1 -r -f1 "." $ytfile[$i])
            # see apple-digital-masters.pdf (soundcheck was too quiet)
            afconvert $ytfile[$i] $filename.caf -d 0 -f caff
            afconvert $filename.caf -d aac -f m4af -u pgcm 2 -b 256000 -q 127 -s 2 "$folder/$title[$i].m4a"
        end
    else
        for i in (seq (count $ytfile))
            mv $ytfile[$i] $folder
        end
    end
    builtin echo "downloaded and converted $cname successfully"

    if not set -q _flag_k
    	$TRASH_EXECUTABLE $tmpdir
    	builtin echo "deleted intermediary files"
    else
        builtin echo "intermediary files can be found in $tmpdir"
    end

    if not set -q _flag_d
        and not set -q _flag_w
        if test (count $title) -gt 1
            set parg \"$folder\"
        else
            set parg \"$PWD/$title.m4a\"
        end
        builtin echo "opening picard..."
        eval $PICARD_EXECUTABLE $parg
    end
end

