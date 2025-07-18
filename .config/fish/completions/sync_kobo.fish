complete -c sync_kobo -l output -d 'Output to file instead of using the standard output' -r
complete -c sync_kobo -l book -d 'Output annotations and highlights only from the book with the given title' -r
complete -c sync_kobo -l id -d 'Output annotations and highlights only from the book with the given ID' -r
complete -c sync_kobo -l csv -d 'Output in CSV format instead of human-readable format'
complete -c sync_kobo -l kindle -d 'Output in Kindle \'My Clippings.txt\' format instead of human-readable format'
complete -c sync_kobo -l list -d 'List the titles of books with annotations or highlights'
complete -c sync_kobo -l annotations-only -d 'Outputs annotations only, excluding highlights'
complete -c sync_kobo -l highlights-only -d 'Outputs highlights only, excluding annotations'
complete -c sync_kobo -l info -d 'Print information about the number of annotations and highlights'
complete -c sync_kobo -l raw -d 'Output in raw text instead of human-readable format'
complete -c sync_kobo -s h -l help -d 'Print help'
