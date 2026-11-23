function fish_prompt
    set -l last $status
    set -l arrow (set_color (test $last -eq 0; and echo green; or echo red))'❯ '(set_color normal)
    if contains -- --final-rendering $argv
        echo -n $arrow
        return
    end
    echo
    echo -n (set_color --bold cyan)(string replace -r "^$HOME" '~' $PWD)(set_color normal)
    fish_git_prompt (set_color --bold blue)' git:('(set_color normal)'%s'(set_color --bold blue)')'(set_color normal)
    echo
    echo -n $arrow
end
