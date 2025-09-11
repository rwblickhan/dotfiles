# Fish completion for Claude Code

complete -c claude -f

# Options
complete -c claude -s d -l debug -d "Enable debug mode with optional category filtering"
complete -c claude -l verbose -d "Override verbose mode setting from config"
complete -c claude -s p -l print -d "Print response and exit (useful for pipes)"
complete -c claude -l output-format -x -a "text json stream-json" -d "Output format (only works with --print)"
complete -c claude -l include-partial-messages -d "Include partial message chunks as they arrive"
complete -c claude -l input-format -x -a "text stream-json" -d "Input format (only works with --print)"
complete -c claude -l mcp-debug -d "[DEPRECATED] Enable MCP debug mode"
complete -c claude -l dangerously-skip-permissions -d "Bypass all permission checks"
complete -c claude -l replay-user-messages -d "Re-emit user messages from stdin back on stdout"
complete -c claude -l allowedTools -l allowed-tools -d "Comma or space-separated list of tool names to allow"
complete -c claude -l disallowedTools -l disallowed-tools -d "Comma or space-separated list of tool names to deny"
complete -c claude -l mcp-config -d "Load MCP servers from JSON files or strings"
complete -c claude -l append-system-prompt -d "Append a system prompt to the default system prompt"
complete -c claude -l permission-mode -x -a "acceptEdits bypassPermissions default plan" -d "Permission mode to use for the session"
complete -c claude -s c -l continue -d "Continue the most recent conversation"
complete -c claude -s r -l resume -d "Resume a conversation"
complete -c claude -l model -d "Model for the current session"
complete -c claude -l fallback-model -d "Enable automatic fallback to specified model"
complete -c claude -l settings -d "Path to a settings JSON file or a JSON string"
complete -c claude -l add-dir -d "Additional directories to allow tool access to"
complete -c claude -l ide -d "Automatically connect to IDE on startup"
complete -c claude -l strict-mcp-config -d "Only use MCP servers from --mcp-config"
complete -c claude -l session-id -d "Use a specific session ID for the conversation"
complete -c claude -s v -l version -d "Output the version number"
complete -c claude -s h -l help -d "Display help for command"

# Commands
complete -c claude -n "__fish_use_subcommand" -a "config" -d "Manage configuration"
complete -c claude -n "__fish_use_subcommand" -a "mcp" -d "Configure and manage MCP servers"
complete -c claude -n "__fish_use_subcommand" -a "migrate-installer" -d "Migrate from global npm installation to local installation"
complete -c claude -n "__fish_use_subcommand" -a "setup-token" -d "Set up a long-lived authentication token"
complete -c claude -n "__fish_use_subcommand" -a "doctor" -d "Check the health of your Claude Code auto-updater"
complete -c claude -n "__fish_use_subcommand" -a "update" -d "Check for updates and install if available"
complete -c claude -n "__fish_use_subcommand" -a "install" -d "Install Claude Code native build"

# Model completions
complete -c claude -l model -x -a "sonnet opus haiku" -d "Model alias"
complete -c claude -l fallback-model -x -a "sonnet opus haiku" -d "Fallback model alias"