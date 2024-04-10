{
  pkgs,
  username,
  fullName,
  ...
}: {
  home = {
    inherit username;
    homeDirectory =
      if pkgs.stdenv.isLinux
      then "/home/${username}"
      else "/Users/${username}";

    stateVersion = "22.11";

    # FIXME: Set your preferred editor
    sessionVariables.EDITOR = "${pkgs.lunarvim}/bin/lvim";

    file = {
      # FIXME: Commit your own configs under ./files/* and copy them over
      # the key in this object is the destination of the file on the host under $HOME
      # ".config/lvim/config.lua".source = "${self.outPath}/files/lvim_config.lua";
    };

    # FIXME: All the packages you can't live without: https://search.nixos.org/packages?channel=unstable
    packages = with pkgs.unstable; [
      # FIXME: Uncomment whatever you actually want
      # bat
      # bottom
      # coreutils
      # curl
      # du-dust
      # fd
      # findutils
      # git
      # git-crypt
      # htop
      # jless
      # jq
      # just
      # killall
      # lunarvim
      # mosh
      # procs
      # pup
      # ripgrep
      # sd
      # sops
      # ssh-to-age
      # tmux
      # tree
      # unzip
      # wget
      # yq
      # zip

      # rustup

      # awscli2
      # deploy-rs
      # httpie

      # tree-sitter

      # # language servers
      # nodePackages.vscode-langservers-extracted # html, css, json, eslint
      # nodePackages.yaml-language-server
      # sumneko-lua-language-server
      # nil # nix

      # # formatters and linters
      # alejandra # nix
      # deadnix # nix
      # lua52Packages.luacheck
      # nodePackages.prettier
      # shellcheck
      # shfmt
      # statix # nix
    ];
  };

  # FIXME: Find more options here https://mipmip.github.io/home-manager-option-search/?query=programs.
  programs = {
    home-manager.enable = true;
    nix-index.enable = true;
    nix-index-database.comma.enable = true;
    lsd.enable = true;
    lsd.enableAliases = true;
    zoxide.enable = true;
    broot.enable = true;
    direnv.enable = true;
    direnv.nix-direnv.enable = true;
    zellij.enable = true;

    git = {
      enable = true;
      package = pkgs.unstable.git;
      delta.enable = true;
      delta.options = {
        line-numbers = true;
        side-by-side = true;
        navigate = true;
      };
      # FIXME: Make sure you add your real corp email address!
      userEmail = "${username}@super.duper.big.corp.com";
      userName = fullName;
      extraConfig = {
        push = {
          default = "current";
          autoSetupRemote = true;
        };
        merge = {
          conflictstyle = "diff3";
        };
        diff = {
          colorMoved = "default";
        };
      };
    };

    starship = {
      enable = true;
      settings = {
        aws.disabled = true;
        gcloud.disabled = true;
        kubernetes.disabled = false;
        git_branch.style = "242";
        directory = {
          tyle = "blue";
          runcate_to_repo = false;
          runcation_length = 8;
        };
        python.disabled = true;
        ruby.disabled = true;
        hostname = {
          ssh_only = false;
          style = "bold green";
          disabled = false;
        };
      };
    };

    fzf = rec {
      enable = true;
      package = pkgs.unstable.fzf;
      defaultCommand = "${pkgs.unstable.fd}/bin/fd --type f --strip-cwd-prefix --hidden --follow --exclude result --exclude .git";
      fileWidgetCommand = defaultCommand;
    };
  };
}
