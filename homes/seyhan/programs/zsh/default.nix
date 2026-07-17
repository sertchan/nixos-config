_: {
  programs.zsh = {
    enable = true;

    shellAliases = {
      ranger = ''ranger --choosedir=$HOME/.rangerdir; LASTDIR=`cat $HOME/.rangerdir`; cd "$LASTDIR"'';
    };

    initContent = ''
      export GPG_TTY=$(tty)
    '';
  };
}
