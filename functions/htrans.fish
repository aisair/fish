function htrans --description 'htrans max_init_lvl max_final_level'
    set hc (math '4.135*(10^-15)*2.998*(10^8)');
    for x in (seq $argv[2])
        set_color green
        builtin echo "Transitions to n = $x"
        set_color normal
        for y in (seq $argv[1])
            if test $y -gt $x
                set E_gamma (math "(-13.6/($y^2)) - (-13.6/($x^2))")
                set lambda (math "(10^9) * $hc/$E_gamma")
                builtin echo "n_i = $y, n_f = $x, E_gamma (eV) = $E_gamma, lambda (nm) = $lambda"
            end
        end
    end
end
