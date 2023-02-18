function kpdl --description "Fetches kaltura playlist information with jq and downloads it with yt-dlp"
    if not count $argv > /dev/null
        echo 'you forgor the playlist link 💀'
        return 1
    end

    argparse "h/help" "m/metadata" -- $argv
    or begin
        builtin echo "argument parsing failed!"
        return 1
    end

    set json (curl $argv[1] | string match --regex --groups-only '({"playlistContent".+}),')
    set ids (echo $json | jq --raw-output '.playlistContent' | string split ",")
    set name (echo $json | jq --raw-output '.name')

    echo "found $(count $ids) video ids, downloading...(this may take a while)"
    for x in $ids
        set link "https://mediaspace.illinois.edu/media/t/$x"
        yt-dlp --ignore-config --quiet $link
    end

    # this was here for exporting to metadataify.fish
    # if set -q _flag_e
    #     echo $test | jq -r '.name' > pltitle.txt
    # end

    if set -q _flag_m
        mkdir metadatad
        for x in *.m4v
            set data (string match -r 'Module ([\d\.]+) - (.+) \[' $x)
            ffmpeg -i $x -codec copy -map_metadata 0 -metadata episode_sort=$data[2] -metadata title=$data[3] -metadata season_number=1 -metadata show="MATH 257 Lecture Videos" "./metadatad/$x"
        end
    end

    echo "finished!~ 🐬"
end
