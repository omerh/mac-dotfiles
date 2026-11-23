# Stock fish prompt minus the hostname, with the input on its own line
function fish_prompt
    set -l last_pipestatus $pipestatus
    set -lx __fish_last_status $status # Export for __fish_print_pipestatus.
    set -l normal (set_color normal)
    set -l prompt_status (__fish_print_pipestatus "[" "]" "|" (set_color $fish_color_status) (set_color --bold $fish_color_status) $last_pipestatus)

    echo -s (set_color $fish_color_user) $USER $normal ' ' (set_color --bold cyan) (prompt_pwd --dir-length 0) $normal (fish_vcs_prompt) $normal ' ' $prompt_status
    echo -n '> '
end
