{ pkgs, ... }:
{
  # Install vim-plug to ~/.vim/autoload/plug.vim
  home.file = {
    ".vim/autoload/plug.vim" = {
      source = pkgs.fetchurl {
        url = "https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim";
        sha256 = "sha256-LuxOfosU4RpHmTz5euO9rGi186fel8CBQXzOPxZDK7E=";
      };
    };
  };

  # Post-activation: run PlugInstall if vim is available
  home.activation.vimPlugInstall = config.lib.dag.entryAfter [ "writeBoundary" ] ''
    if command -v vim >/dev/null 2>&1; then
      echo "Running PlugInstall to install Vim plugins..."
      vim +PlugInstall +qall || true
    fi
  '';
}
