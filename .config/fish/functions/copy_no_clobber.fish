function copy_no_clobber
    set src $argv[1]
    set dst $argv[2]
    for file in $src/*
        if test -f $file; and not test -e $dst/(basename $file)
            echo "Copying $file"
            cp $file $dst
        end
    end
end
