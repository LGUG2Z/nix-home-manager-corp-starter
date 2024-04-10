{
  pkgs,
  username,
  nix-index-database,
  ...
}: {
  # FIXME: Uncomment this if you want the Fish config on your Macbook
  # imports = [
  #   ./fish.nix
  # ];

  # TODO: If you really want to, you can declaratively configure most of your macOS options
  # https://daiderd.com/nix-darwin/manual/index.html

  users.users.${username}.home = "/Users/${username}";
  services.nix-daemon.enable = true;

  # FIXME: If you want to use touchid for sudo make sure you've set a fingerprint
  security.pam.enableSudoTouchIdAuth = true;

  nix = {
    # This allows us to cross-compile any package from aarch64-darwin to aarch64-linux and x86_64-linux
    settings.trusted-users = ["@admin"];
    distributedBuilds = true;
    linux-builder = {
      package = pkgs.unstable.darwin.linux-builder;
      enable = true;
      ephemeral = true;
      maxJobs = 4;
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];
      # FIXME: Apply this once without the config to bootstrap the builder, then uncomment this line and run apply it again
      # config = {
      #   boot.binfmt.emulatedSystems = [
      #     "x86_64-linux"
      #   ];
      # };
    };

    extraOptions = ''
      extra-platforms = aarch64-darwin x86_64-darwin
      experimental-features = nix-command flakes
    '';
  };

  home-manager.users.${username} = {
    imports = [
      nix-index-database.hmModules.nix-index
      # FIXME: Uncomment this if you want the settings in home.nix on your Macbook
      # ./home.nix
    ];

    home = {
      inherit username;
      homeDirectory =
        if pkgs.stdenv.isLinux
        then "/home/${username}"
        else "/Users/${username}";

      stateVersion = "22.11";
      packages = [
        pkgs.unstable.deploy-rs
      ];
    };

    programs = {
      nix-index.enable = true;
      nix-index-database.comma.enable = true;
    };
  };
}
