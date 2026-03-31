# Install Nix
sh <(curl --proto '=https' --tlsv1.2 -L https://nixos.org/nix/install)
zsh

# Install home manager
nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager
nix-channel --update
nix-shell '<home-manager>' -A install
zsh


