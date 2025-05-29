# Print an optspec for argparse to handle cmd's options that are independent of any subcommand.
function __fish_sync_bookmarks_global_optspecs
	string join \n h/help V/version
end

function __fish_sync_bookmarks_needs_command
	# Figure out if the current invocation already has a command.
	set -l cmd (commandline -opc)
	set -e cmd[1]
	argparse -s (__fish_sync_bookmarks_global_optspecs) -- $cmd 2>/dev/null
	or return
	if set -q argv[1]
		# Also print the command, so this can be used to figure out what it is.
		echo $argv[1]
		return 1
	end
	return 0
end

function __fish_sync_bookmarks_using_subcommand
	set -l cmd (__fish_sync_bookmarks_needs_command)
	test -z "$cmd"
	and return 1
	contains -- $cmd[1] $argv
end

complete -c sync_bookmarks -n "__fish_sync_bookmarks_needs_command" -s h -l help -d 'Print help'
complete -c sync_bookmarks -n "__fish_sync_bookmarks_needs_command" -s V -l version -d 'Print version'
complete -c sync_bookmarks -n "__fish_sync_bookmarks_needs_command" -f -a "raindrop"
complete -c sync_bookmarks -n "__fish_sync_bookmarks_needs_command" -f -a "import"
complete -c sync_bookmarks -n "__fish_sync_bookmarks_needs_command" -f -a "help" -d 'Print this message or the help of the given subcommand(s)'
complete -c sync_bookmarks -n "__fish_sync_bookmarks_using_subcommand raindrop" -s h -l help -d 'Print help'
complete -c sync_bookmarks -n "__fish_sync_bookmarks_using_subcommand import" -s v -l verbose
complete -c sync_bookmarks -n "__fish_sync_bookmarks_using_subcommand import" -s h -l help -d 'Print help'
complete -c sync_bookmarks -n "__fish_sync_bookmarks_using_subcommand help; and not __fish_seen_subcommand_from raindrop import help" -f -a "raindrop"
complete -c sync_bookmarks -n "__fish_sync_bookmarks_using_subcommand help; and not __fish_seen_subcommand_from raindrop import help" -f -a "import"
complete -c sync_bookmarks -n "__fish_sync_bookmarks_using_subcommand help; and not __fish_seen_subcommand_from raindrop import help" -f -a "help" -d 'Print this message or the help of the given subcommand(s)'
