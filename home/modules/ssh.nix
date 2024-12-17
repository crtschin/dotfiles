{
  ...
}:
{
  # Create the systemd agent unit and set up the environment variable for the socket.
  # I'm not using home-manager for this since it will want to run the ssh-agent from within
  # nix, and I just want to run the default one from the system!
  home.sessionVariablesExtra = ''
    export SSH_AUTH_SOCK=$XDG_RUNTIME_DIR/ssh-agent.socket
  '';

  home.file.".config/systemd/user/ssh-agent.service".text = ''
    [Unit]
    Description=SSH key agent

    [Service]
    Type=simple
    Environment=SSH_AUTH_SOCK=%t/ssh-agent.socket
    ExecStart=/usr/bin/ssh-agent -D -a $SSH_AUTH_SOCK

    [Install]
    WantedBy=default.target
  '';
}
