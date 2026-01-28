# Read from ~/.envs and set environment variables.
if test -f ~/.envs
  for line in (cat ~/.envs | sed 's|#.*||' | sed 's/^[ \t]*//;s/[ \t]*$//' | string split -n "\n")
    # skip comments
    if test (string sub --length 1 "$line") = "#"
        continue  
    end

    set item (string split -m 1 "=" $line)
    
    if test (count $item) -eq 2
      set key (string trim $item[1])
      set value (string trim $item[2])

      set expanded_value (string replace '$HOME' "$HOME" (string replace '~' "$HOME" "$value"))
      
      set -gx $key $expanded_value
    end
  end
end

if test -f "$HOME/.envs.environment"
    for line in (cat "$HOME/.envs.environment" | sed 's|#.*||' | sed 's/^[ \t]*//;s/[ \t]*$//' | string split -n "\n")
        # skip comments
        if test (string sub --length 1 "$line") = "#"
            continue  
        end

        set item (string split -m 1 "=" $line)
        
        if test (count $item) -eq 2
          set key (string trim $item[1])
          set value (string trim $item[2])

          set expanded_value (string replace '$HOME' "$HOME" (string replace '~' "$HOME" "$value"))
          
          set -gx $key $expanded_value
        end
    end
end
