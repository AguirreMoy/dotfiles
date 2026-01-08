

# Read from ~/.paths  and populate PATH based on that. reversed to ensure priority goes to top of file.
for line in (cat ~/.paths  | sed 's|#.*||' | sed 's/^[ \t]*//;s/[ \t]*$//' | string split -n "\n")
  # skip comments
  if test (string sub --length 1 "$line") = "#"
      continue  
  end

  set expanded_line (string replace '$HOME' "$HOME" (string replace '~' "$HOME" "$line"))

  if test -d "$expanded_line" -o -L "$expanded_line"
    fish_add_path --global "$expanded_line"
  else
    # echo "Warning: Path '$expanded_line' does not exist or is not a directory/symlink. Skipping." >&2
  end
end
