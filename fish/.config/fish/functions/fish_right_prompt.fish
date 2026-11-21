function fish_right_prompt
    set -l parts
    set -q AWS_PROFILE; and test "$AWS_PROFILE" != default; and set -a parts (set_color yellow)aws_profile=$AWS_PROFILE
    set -q AWS_REGION; and set -a parts (set_color yellow)aws_region=$AWS_REGION
    test -d .terraform; and set -a parts (set_color magenta)tf=(cat .terraform/environment 2>/dev/null; or echo default)
    set -q VIRTUAL_ENV; and set -a parts (set_color green)venv=(path basename $VIRTUAL_ENV)
    set -q KUBECONFIG; and set -a parts (set_color blue)ctx=(kubectl config current-context 2>/dev/null | string replace -r '.*cluster/' '')
    test "$CMD_DURATION" -ge 500; and set -a parts (set_color yellow)(math -s1 $CMD_DURATION / 1000)s
    echo -n $parts(set_color normal)
end
