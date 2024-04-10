{
  pkgs,
  username,
  ...
}: let
  shell = import ./shell.nix {};
  inherit (shell) git_shortcuts navigation_shortcuts;
in {
  home.sessionVariables.SHELL = pkgs.lib.mkDefault "/etc/profiles/per-user/${username}/bin/fish";

  programs = {
    fzf.enableFishIntegration = true;
    nix-index.enableFishIntegration = true;
    zoxide.enableFishIntegration = true;
    broot.enableFishIntegration = true;

    # FIXME: If you want zsh instead, look here to build your zshrc in a dedicated ./modules/zsh.nix file: https://mipmip.github.io/home-manager-option-search/?query=programs.zsh
    fish = {
      enable = true;

      # FIXME: Set your own theme (instead of kanagawa) if you want
      interactiveShellInit = ''
        ${pkgs.any-nix-shell}/bin/any-nix-shell fish --info-right | source

        ${pkgs.lib.strings.fileContents (pkgs.fetchFromGitHub {
            owner = "rebelot";
            repo = "kanagawa.nvim";
            rev = "de7fb5f5de25ab45ec6039e33c80aeecc891dd92";
            sha256 = "sha256-f/CUR0vhMJ1sZgztmVTPvmsAgp0kjFov843Mabdzvqo=";
          }
          + "/extras/kanagawa.fish")}

        set -U fish_greeting
        fish_add_path ~/.cargo/bin
      '';

      # FIXME: Add other functions if  you want
      functions = {
        refresh = "source $HOME/.config/fish/config.fish";
        take = ''mkdir -p -- "$1" && cd -- "$1"'';
        ttake = "cd $(mktemp -d)";
        show_path = "echo $PATH | tr ' ' '\n'";
        posix-source = ''
          for i in (cat $argv)
            set arr (echo $i |tr = \n)
            set -gx $arr[1] $arr[2]
          end
        '';
      };

      # FIXME: Add other abbrs if you want
      shellAbbrs =
        {
          gc = "nix-collect-garbage --delete-old";
        }
        // git_shortcuts
        // navigation_shortcuts;

      # FIXME: Add other aliases if you want
      shellAliases = {
        cd = "z";
      };

      # FIXME: Add other plugins if you want
      plugins = [
        {
          inherit (pkgs.fishPlugins.autopair) src;
          name = "autopair";
        }
        {
          inherit (pkgs.fishPlugins.done) src;
          name = "done";
        }
        {
          inherit (pkgs.fishPlugins.sponge) src;
          name = "sponge";
        }
      ];
    };
  };
}
