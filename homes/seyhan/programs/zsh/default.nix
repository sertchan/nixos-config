_: {
  programs.zsh = {
    enable = true;

    shellAliases = {
      # Change working directory to ranger's last visited directory on exit
      ranger = ''ranger --choosedir=$HOME/.rangerdir; LASTDIR=`cat $HOME/.rangerdir`; cd "$LASTDIR"'';
    };

    initContent = ''
      export GPG_TTY=$(tty) # Register active TTY for GPG passphrase prompts
    '';
  };
}
