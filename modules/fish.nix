{
  pkgs,
  username,
  ...
}: {
  programs.fish.enable = true;
  users.users.${username}.shell = pkgs.fish;
  environment.pathsToLink = ["/share/fish"];
  environment.shells = [pkgs.fish];
  home-manager.users.${username} = {
    imports = [./home-fish.nix];
  };
}
