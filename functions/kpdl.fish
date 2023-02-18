function kpdl --description "Fetches kaltura playlist and downloads it with yt-dlp"
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
    set ids (echo $json | jq -r '.playlistContent' | string split ",")

    echo "found $(count $ids) video ids, downloading...(this may take a while)"
    for x in $ids
        set link "https://mediaspace.illinois.edu/media/t/$x"
        echo "downloading $link"
        yt-dlp --ignore-config --quiet $link
    end

    # this was here for exporting to metadataify.fish
    # if set -q _flag_e
    #     echo $test | jq -r '.name' > pltitle.txt
    # end

    echo "finished!~ 🐬"
end
