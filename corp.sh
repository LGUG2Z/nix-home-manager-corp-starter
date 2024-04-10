#!/usr/bin/env bash

GREEN='\033[0;32m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
RESET='\033[0m'

if [[ $# -eq 0 ]]; then
  echo -e "try calling this script again with your virtual workstation's hostname or ip address"
  echo -e
  echo -e "for example: ./corp.sh lgug2z.super.duper.big.corp.com"
  exit 1
fi

HOST=${1}

echo -e "${GREEN}remote${RESET}: ensuring nix is installed"
ssh -T "${HOST}" <<'ENDSSH'
if [ ! -d "/nix/store" ]; then
  NIX_BUILD_GROUP_ID=20000000 NIX_FIRST_BUILD_UID=20000000 sh <(curl -L https://nixos.org/nix/install) --daemon
fi
ENDSSH

echo -e "${GREEN}remote${RESET}: ensuring nix-* binaries are symlinked to /usr/bin/ for remote home-manager activations"
ssh -T "${HOST}" <<'ENDSSH'
for f in /nix/var/nix/profiles/default/bin/nix-*; do
  sudo ln -fs "$f" "/usr/bin/$(basename "$f")"
done
ENDSSH

echo -e "${GREEN}remote${RESET}: ensuring home-manager is installed"
ssh -T "${HOST}" <<'ENDSSH'
[[ $(nix-channel --list) != *"home-manager"* ]] && (nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager && nix-channel --update)

if [ ! -f /home/${USER}/.nix-profile/etc/profile.d/hm-session-vars.sh ]; then
  nix-shell '<home-manager>' -A install
fi
ENDSSH

echo -e "\n${PURPLE}you are now ready to apply a home-manager configuration to ${HOST}${RESET} 🎉"
echo -e "\nonce you have made your changes (grep '# FIXME' */**) you can run 'deploy -s .#corp' 🚀"
