{username, ...}: {
  home = {
    sessionVariables.SHELL = "/home/${username}/.nix-profile/bin/fish";

    # FIXME: Add any corp-specific configs and files here
  };
}
