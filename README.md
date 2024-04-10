# nix-home-manager-corp-starter

This repository is intended to be a sane, batteries-included starter template
for creating reproducible cloud development machines in corporate
environments where users may be restricted to the use of a single
company-approved Linux distribution.

This starter assumes some knowledge of the Nix ecosystem. If you are new to
Nix, I recommend checking out my
[`nixos-hetzner-cloud-starter`](https://github.com/LGUG2Z/nixos-hetzner-cloud-starter)
template which is aimed at people who are completely new to Nix.

Make sure to look at all the `FIXME` notices in the various files which are
intended to direct you to places where you may want to make configuration
tweaks.

If you found this starter template useful, please consider
[sponsoring](https://github.com/sponsors/LGUG2Z) and [subscribing to my YouTube
channel](https://www.youtube.com/channel/UCeai3-do-9O4MNy9_xjO6mg?sub_confirmation=1).

## Macbook Setup

For Macbook users, in order to deploy a `home-manager` configuration to a
remote host, you need to have
[`nix`](https://nixos.org/download#nix-install-macos) installed on your
Macbook.

```bash
sh <(curl -L https://nixos.org/nix/install)
```

Clone this repo, update all of the `# FIXME` notices for your default user
information and the hostname of your machine, and then build and apply the
configuration.

The applied configuration ensures that we are able to use the `linux-builder`
module to build any packages for both `x86_64-linux` and `aarch64-linux`
architectures. (Check out [./modules/darwin.nix](./modules/darwin.nix) for
details)

```bash
nix build .#darwinConfigurations.<YOUR HOSTNAME GOES HERE>.system --extra-experimental-features "nix-command flakes"
./result/sw/bin/darwin-rebuild switch --flake .
```

You should `ssh` into your cloud development machine at least once before continuing to
ensure that the hostkeys are added to `~/.ssh/known_hosts`.

## Cloud Development Machine Preparation

Run `./corp.sh your.cloud.development.machine.hostname.bigcorp.com` to prepare
the host to receive `home-manager` configurations.

This script installs the Nix package manager, `home-manager` and ensures that
`nix-*` binaries are symlinked to `/usr/bin` to allow for smooth remote
`home-manager` activations.

Take a look at [./corp.sh](./corp.sh) to make any tweaks for your specific
company use case.

## Applying the Home Manager Configuration

Once the host has been prepared, you can run the following command on your
Macbook to build and apply the `home-manager` configuration to the host. 

```bash
deploy -s .#corp
```

I recommend not making too many changes the first time you apply your
configuration; the committed configuration has been tested to work on first
apply.

`ssh` into your machine and run `fish`, then check out all the generated
dotfiles under `~/.config` and all the binaries in your `$PATH`.

You may want to make updates where there are `# FIXME` notices in
[./modules/home.nix](./modules/home.nix),
[./modules/shell.nix](./modules/shell.nix),
[./modules/corp.nix](./modules/corp.nix), and
[./modules/home-fish.nix](./modules/home-fish.nix).

In particular you may want to add configuration files to your fork of this repo
in `./files/*` and have them automatically synced over to the host.

Note that any new files added must be `git add`ed before they will be
considered deployable.

## Making and Deploying Changes

Whenever you have new configuration changes to deploy (new packages, new
dotfiles etc.), run the same `deploy -s .#corp` command.

## Multiple Hosts, Multiple Architectures

You can also target multiple hosts, for example, below we target an
`x86-64-linux` host and an `aarch64-linux` host. Both will have exactly the
same configurations and the cross-compilations of all packages will be handled
transparently.

The new host can be targeted by using the node name: `deploy -s .#arm-corp`.

```nix
{
    homeConfigurations.corp = mkHomeManagerConfiguration {
        system = "x86_64-linux";
        modules = [
          ./modules/home.nix
          ./modules/home-fish.nix
          ./modules/corp.nix
        ];
    };

    homeConfigurations.arm-corp = mkHomeManagerConfiguration {
        system = "aarch64-linux";
        # we can include an override for the hostname here
        hostname = "arm.lgug2z.super.duper.big.corp.com";
        modules = [
          ./modules/home.nix
          ./modules/home-fish.nix
          ./modules/corp.nix
        ];
    };

    deploy = {
        autoRollback = false;
        magicRollback = false;
        nodes = {
          corp = rec {
            inherit (self.homeConfigurations.corp.options._module.specialArgs.value) hostname;
            sshUser = self.homeConfigurations.corp.config.home.username;
            user = self.homeConfigurations.corp.config.home.username;
            remoteBuild = true;
            profiles.dev = {
              path = (nixpkgsWithOverlays self.homeConfigurations.corp.activationPackage.system).deploy-rs.lib.activate.home-manager self.homeConfigurations.corp;
              profilePath = "/home/${user}/.local/state/nix/profiles/dev";
            };
          };

          arm-corp = rec {
            inherit (self.homeConfigurations.arm-corp.options._module.specialArgs.value) hostname;
            sshUser = self.homeConfigurations.arm-corp.config.home.username;
            user = self.homeConfigurations.arm-corp.config.home.username;
            remoteBuild = true;
            profiles.dev = {
              path = (nixpkgsWithOverlays self.homeConfigurations.arm-corp.activationPackage.system).deploy-rs.lib.activate.home-manager self.homeConfigurations.arm-corp;
              profilePath = "/home/${user}/.local/state/nix/profiles/dev";
            };
          };
        };
    };
}
```
