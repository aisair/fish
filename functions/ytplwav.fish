# this function is redundant since i implemented playlist features into the ytdlwav function but i'll keep it here

function ytplwav
    if not count $argv > /dev/null
        echo 'you forgor the link 💀'
        return 1
    end
    argparse "h/help" -- $argv
    or begin
        set_color yellow
        echo "warn: argument parsing failed!"
        set_color normal
        return 1
    end

    if set -q _flag_h
        builtin printf '%s\n' "ytplwav Help" "Parses YT playlist with jq then sends to ytdlwav" "Usage:" "ytdlwav [-h] target_url" "-h or --help: prints this help sheet"
        return
    end

    builtin echo "fetching and parsing YT playlist information..."
    set ytids (yt-dlp -J $argv[1] | jq -r ".title, .entries[].id")
    builtin echo "downloading $ytids[1]"
    set -e ytids[1]

    for x in $ytids
        builtin echo "downloading YT id $x"
        ytdlwav $x
    end

    builtin echo "finished downloading playlist!"
    eval $PICARD_EXECUTABLE \"$PWD/$title.m4a\"
end
