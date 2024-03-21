function kpdl --description "Fetches kaltura playlist information with jq and downloads it with yt-dlp"
    if not count $argv > /dev/null
        builtin echo 'you forgor the playlist link 💀'
        return 1
    end

    argparse 'm/metadata' -- $argv
    or begin
        builtin echo 'argument parsing failed!'
        return 1
    end

    if type -fq jq
        builtin echo "jq isn't installed and in your PATH!"
        return 1
    end
    
    if type -fq curl
        builtin echo "curl isn't installed and in your PATH!"
        return 1
    end

    set json (curl --silent $argv[1] | builtin string match --regex --groups-only '({"playlistContent".+}),')
    set ids (builtin echo $json | jq --raw-output '.playlistContent' | builtin string split ",")
    set name (builtin echo $json | jq --raw-output '.name')

    builtin echo "downloading $name (found $(count $ids) video ids, this may take a while)"
    mkdir -p $name
    set folder (path resolve ./$name)
    for x in $ids
        set link "$(builtin string split -f1,3 -m3 '/' $argv[1] | builtin string join '//')/media/t/$x"
        # set -a titles (yt-dlp --ignore-config --quiet --print title $link) # debug
        set -a titles (yt-dlp --ignore-config --quiet --no-warnings --no-simulate --paths $folder --print title $link)
    end

    if set -q _flag_m
        set files (path resolve $folder/*)
        builtin echo "applying metadata to files"
        for i in (seq (count $files))
            set x $files[$i]
            ffmpeg -loglevel error -i $x -codec copy -map_metadata 0 -metadata season_number=1 -metadata episode_sort=$i -metadata title=$titles[$i] -metadata show=$name "$folder/$titles[$i]$(path extension $x)"
        end
    end

    builtin echo "finished!~ 🐬"
end
