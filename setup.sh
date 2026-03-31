#!/usr/bin/env bash

set -e

if command -v nix >/dev/null 2>&1; then
  echo "nix already installed"
else
  # Install Nix
  sh <(curl --proto '=https' --tlsv1.2 -L https://nixos.org/nix/install)
  zsh
fi

if command -v home-manager >/dev/null 2>&1; then
  echo "home manager already installed"
else
  # Install home manager
  nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager
  nix-channel --update
  nix-shell '<home-manager>' -A install
  zsh
fi

echo "updating home manager config"

HM_CFG_DIR=~/.config/home-manager
HM_FOLDERS=("aliases" "git_includes")

for FOLDER in "${HM_FOLDERS[@]}"; do
  mkdir -p "${HM_CFG_DIR}/${FOLDER}"
  
  if [ -d "${FOLDER}" ]; then
    cp -r "${FOLDER}/" "${HM_CFG_DIR}/${FOLDER}"
  fi
done

cp ./home.nix ${HM_CFG_DIR}/home.nix

home-manager switch
zsh


