alias nrc='nix shell -f default.nix -c'

# Functions

function pfw
    gcloud compute ssh --tunnel-through-iap $argv -- -L 5501:localhost:5432 -N
end

function workon
    source ~/env/$1/bin/activate
end

function set_scale
    gsettings set org.gnome.desktop.interface text-scaling-factor "$argv[1]"
end

function tag
    set ver (git describe --abbrev=0)
    string match -rq '(?<last_tag>\d+)' -- $ver
    set new_ver (math $last_tag + 1)
    git tag -a v"$new_ver" -m v"$new_ver"
end

function diffsbs
    git config delta.side-by-side "$argv"
end

function release-check
    # get the last tag
    set lasttag (git describe --abbrev=0 --tags)
    # Get the amount of files changed
    set change_count (git diff --name-only --diff-filter=AMDR $lasttag...@ | wc -l)
    # Get the amount of alembics that where changed
    set alembic_count (git diff --name-only --diff-filter=AMDR  $lasttag...@ -- alembic | wc -l)

    # Check if the release contains alembics
    if test $alembic_count -eq 0 && test $change_count -ne 0
        echo -e "\033[0;32mRelease contains no alembics\033[0m"
    else if test $change_count -ne 0
        echo -e "\033[0;31mRelease contains $alembic_count alembic(s)\033[0m"
    end

    # Check the change log
    if test $change_count -eq 0
        echo -e "No changes since \033[0;32m$lasttag\033[0m"
    else
        echo -e "\nChange log since \033[0;32m$lasttag\033[0m:"
        git shortlog $lasttag...@
    end
end

# function diff
#   git diff --no-index "$argv"
# end

function overmind
    nix shell nixpkgs.overmind -c overmind start
end

function nrun
    nix shell -f default.nix -c $argv
end

function giffify --description "giffify <video_file> <gif_name>"
    ffmpeg -i $argv[1] -r 15 -vf "scale=1024:-1,split[s0][s1];[s0]palettegen[p];[s1][p]paletteuse" $argv[2].gif
end

alias grep='grep --color=auto'
alias gssh='gcloud compute ssh --tunnel-through-iap '

alias gcloud-operations-log='gcloud compute operations list --format=":(TIMESTAMP.date(tz=LOCAL))" --sort-by=TIMESTAMP'
alias with-cachix-key="vaultenv --secrets-file (echo \"cachix#signing-key\" | psub) -- "

alias ndb='nrc ./with-test-db.sh $SHELL'
alias path='echo $PATH'

alias codesec='nrc vaultenv -- code . --wait'
alias codes='nrc code . --wait'
alias watch='watch -d'

# set --export PATH "$HOME/.local/bin:$PATH"
set --export LC_ALL "C.UTF-8"

# Rust
# bass source "$HOME/.cargo/env"

set fish_greeting
set -U __done_notify_sound 1

# As a reminder for fzf keybindings
# Ctrl + F       : file search
# Ctrl + Alt + S : git status search
# Ctrl + Alt + L : git log search
# Ctrl + R       : reverse-i-search (search command history)
# Ctrl + V       : variable search

# Non-nixos specific commands
set --export NIX_PATH $NIX_PATH:$HOME/.nix-defexpr/channels

# if ! (ip addr | grep -q 'inet 1.2.3.4/32 scope global lo');
#     echo "Setting up 1.2.3.4 loopback"
#     sudo ip addr add 1.2.3.4/32 dev lo
# end

# Deploying workflow
# > git tag -a v# -m v#
# > git push origin master --follow-tags
# if alembic:
#   > git checkout v#
#   > ./built.py run alembic-prod upgrade +1
# cd devops/ansible
# Wait for semaphore to cache tags
#   Set version number in devops repo and commit
# > nrc provision ARG --environment staging --check
# > nrc provision ARG --environment staging
# > nrc provision ARG --environment production
#
# Connecting production postgres
# Setup postgres port-forwarding with:
# > gssh <server> -- -L 5501:localhost:5432 -N
