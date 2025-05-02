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

function pfp
    nrc python ~/channable/requestmachine/scripts/pull_from_prod_like_a_boss.py --table companies --_id "$argv" --minimal
end

function compare-data
    git diff --color-words --no-index investigation/import-compare-results/"$argv[1]"_import_mapping_v1_data investigation/import-compare-results/"$argv[1]"_import_mapping_v2_data
end

function compare-logs
    git diff --color-words --no-index investigation/import-compare-results/"$argv[1]"_import_mapping_v2_shm_import_stdout.log investigation/import-compare-results/"$argv[1]"_import_mapping_v2_shm_import_stdout.log
end

function tag
    set ver (git describe --abbrev=0)
    string match -rq '(?<last_tag>\d+)' -- $ver
    set new_ver (math $last_tag + 1)
    git tag -a v"$new_ver" -m v"$new_ver"
end

function improd
    improd_shmimport "$argv[1]" &
    improd_analytics "$argv[1]" &
    wait
end

function improd_shmimport
    pushd "$HOME/channable/sharkmachine"
    set project_id "$argv[1]"
    stack exec sharkmachine-import -- \
        --project-id "$project_id" \
        --gcs-bucket normalized_feeds \
        --log-timestamps yes
    popd
end

function improd_analytics
    pushd "$HOME/channable/requestmachine"
    set project_id "$argv[1]"
    nix run --argstr environment dev-python-env "
        set analytics \"(python -c \"from feedscrubber.models.projects import ProjectModel; print(\" \".join([str(a['id']) for a in ProjectModel.get_by_id($project_id).get_analytics()]))\")\"
        echo \"asdasd\"
        if test ! -z "$analytics";
            echo \"YES ANALYTICS $project_id $analytics\"
            ./scripts/pull_from_prod.py --tokens --project "$project_id"
        else
            echo \"NO ANALYTICS\"
        end
        for aid in $analytics;
            ./requestmachine.py download_analytics "$aid";
        done
"
    popd
end

function refresh_prod_token
    set CONNECTION_ID "$argv[1]"
    if string match -req '^[0-9]+$' $CONNECTION_ID
        gssh firehose --zone europe-west1-b "
requestmachine-ipython -c 'from feedscrubber.models.connections import ConnectionModel; ConnectionModel.get_by_id($CONNECTION_ID).get_connection_status().refresh()'
"
    else
        echo "Connection id is not a number"
    end
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

alias adoc='ANSIBLE_COLLECTIONS_PATH=$(nix-build --no-out-link ~/channable/devops/ansible/ansible-collections.nix) nrc ansible-doc'

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

# Channable specific commands
set --export SHARKMACHINE_DUMP_REQUESTS_PATH /home/curtis/channable/tmp
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
# For jobmachine, restart workers.
# First check staging with worker-test
# > gssh jobmachine1
# To force restart preemptible worker
# > jobctl worker restart --direct worker-p-blah
# > uptime
# > sudo journalctl -fu jobmachine
# > jobctl worker restart {Server}
# > jobctl worker restart {Server} --direct

# Connecting jobmachine production postgres
# Setup postgres port-forwarding with:
# > gssh jobmachine1 -- -L 5501:localhost:5432 -N

function _provision_completion
    set -l response

    for value in (env _PROVISION_COMPLETE=fish_complete COMP_WORDS=(commandline -cp) COMP_CWORD=(commandline -t) provision)
        set response $response $value
    end

    for completion in $response
        set -l metadata (string split "," $completion)

        if test $metadata[1] = dir
            __fish_complete_directories $metadata[2]
        else if test $metadata[1] = file
            __fish_complete_path $metadata[2]
        else if test $metadata[1] = plain
            echo $metadata[2]
        end
    end
end

complete --no-files --command provision --arguments "(_provision_completion)"

# BEGIN ANSIBLE MANAGED BLOCK
set --export SSH_ENV "$HOME/.ssh/environment"
set --export LESS -RS

if [ x = x ]
    # if [ x = x ]
    gnome-keyring-daemon --start --components=secrets,ssh | read --line gnome_keyring_control ssh_auth_sock

    set -gx GNOME_KEYRING_CONTROL (string split -m 1 = $gnome_keyring_control)[2]
    set -gx SSH_AUTH_SOCK (string split -m 1 = $ssh_auth_sock)[2]
end

# function start_agent
#     echo "Initialising new SSH agent..."
#     /usr/bin/ssh-agent | sed 's/^echo/#echo/' | set --export "$SSH_ENV"
#     echo Succeeded
#     chmod 600 "$SSH_ENV"
#     bass source "$SSH_ENV" >/dev/null
#     /usr/bin/ssh-add ~/.ssh/google_compute_engine >/dev/null 2>&1
# end

# bass source ~/.config/fish/functions.sh

# if test -f "$SSH_ENV"
#     bass source "$SSH_ENV" >/dev/null
#     kill -0 "$SSH_AGENT_PID" 2>/dev/null || start_agent
# else
#     start_agent
# end
# END ANSIBLE MANAGED BLOCK
