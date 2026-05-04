function fish_user_key_bindings
  fzf_key_bindings

  # Respect ssh when checking for macos terminal keybindings
  bind ctrl-right "if fish_in_macos_terminal_or_ssh; commandline -f forward-token; else commandline -f forward-word; end"
  bind ctrl-left "if fish_in_macos_terminal_or_ssh; commandline -f backward-token; else commandline -f backward-word; end"
  bind alt-right "if fish_in_macos_terminal_or_ssh; commandline -f nextd-or-forward-word; else nextd-or-forward-token; end"
  bind \e\[1\;9C "if fish_in_macos_terminal_or_ssh; commandline -f nextd-or-forward-word; else nextd-or-forward-token; end"
  bind alt-left "if fish_in_macos_terminal_or_ssh; commandline -f prevd-or-backward-word; else prevd-or-backward-token; end"
  bind \e\[1\;9D "if fish_in_macos_terminal_or_ssh; commandline -f prevd-or-backward-word; else prevd-or-backward-token; end"
  bind alt-backspace "if fish_in_macos_terminal_or_ssh; commandline -f backward-kill-word; else commandline -f backward-kill-token; end"
  bind ctrl-alt-h "if fish_in_macos_terminal_or_ssh; commandline -f backward-kill-word; else commandline -f backward-kill-token; end"
  bind ctrl-backspace "if fish_in_macos_terminal_or_ssh; commandline -f backward-kill-token; else commandline -f backward-kill-word; end"
  bind alt-delete "if fish_in_macos_terminal_or_ssh; commandline -f kill-word; else commandline -f kill-token; end"
  bind ctrl-delete "if fish_in_macos_terminal_or_ssh; commandline -f kill-token; else commandline -f kill-word; end"
end
