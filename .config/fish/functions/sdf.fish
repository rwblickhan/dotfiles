function sdf
    sd "$argv[1]" "$argv[2]" (rg --files-with-matches "$argv[1]")
end
