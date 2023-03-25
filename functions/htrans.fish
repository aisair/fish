function htrans --description 'htrans max_init_lvl max_final_level'
    set hc9 (math '4.135*(10^-15)*2.998*(10^8)*(10^9)');
    for f in (seq $argv[2])
        set_color green
        builtin echo "Transitions to n_f = $f"
        set_color normal
        for i in (seq $argv[1])
            if test $i -gt $f
                set E_gamma (math "(-13.6/($i^2)) - (-13.6/($f^2))")
                set lambda (math "$hc9/$E_gamma")
                # set lambda (math "1240/$E_gamma")
                builtin echo "n_i = $i, n_f = $f, E_gamma (eV) = $E_gamma, lambda (nm) = $lambda"
            end
        end
    end
end
