function rename --description 'Rename file based on regex statements'
    # we'll start with a single file lol because that's how i work
    if not count $argv > /dev/null
        builtin echo 'you forgor the file 💀'
        builtin echo 'rename -h for help sheet ❓'
        return 1
    end
    argparse 'h/help' -- $argv
    or begin
        builtin echo 'unknown argument, please check your args'
        return 1
    end 

    if set -q _flag_h
        printf '%s\n' 'rename Help' 'Renames files based on a regular expression' 'Usage:' 'rename [-h] regex_string replace_string file_path' '-h or --help: prints this help sheet'
    end

    if not test -f $argv[3]
        printf 'supplied file does not exist'
        return 1
    end

    mv $argv[-1] (string replace $argv[1] $argv[2] (path basename $argv[-1]))
end
