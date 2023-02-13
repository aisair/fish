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
    end

    if set -q _flag_h
        builtin echo "ytplwav Help\nParses YT playlist then sends to ytdlwav\nUsage:\nytdlwav [-h] target_url\n-h or --help: prints this help sheet"
        return
    end

    builtin echo "downloading and parsing YT playlist information..."
    set ytids (yt-dlp -j $argv[1] | jq -r ".id")

    for x in $ytids
        builtin echo "downloading YT id $x"
        ytdlwav $x
    end

    builtin echo "finished downloading playlist!"
end
