{ config, pkgs, lib, ... }:

let
  # Custom deep merge logic
  deepMerge = a: b:
    if builtins.isAttrs a && builtins.isAttrs b then
      builtins.foldl' (acc: key:
        let
          aval = if acc ? ${key} then acc.${key} else null;
          bval = b.${key};
        in
          acc // {
            ${key} = if aval == null then bval else deepMerge aval bval;
          }
      ) a (builtins.attrNames b)
    else if builtins.isList a && builtins.isList b then
      a ++ b
    else
      b; # Overwrite basic keys (strings, bools, etc)

  # Helper to import and merge a directory of .nix files
  importAndMerge = dir: default:
    let
      contents = builtins.readDir dir;
      files = builtins.filter (n: contents.${n} == "regular" && lib.hasSuffix ".nix" n) (builtins.attrNames contents);
      imported = map (f: import (dir + "/${f}")) files;
    in
      builtins.foldl' deepMerge default imported;

in {
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "sawyer";
  home.homeDirectory = "/Users/sawyer";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "25.11"; # Please read the comment before changing.

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = [
    # # Adds the 'hello' command to your environment. It prints a friendly
    # # "Hello, world!" when run.
    # pkgs.hello
    pkgs.direnv

    # # It is sometimes useful to fine-tune packages, for example, by applying
    # # overrides. You can do that directly here, just don't forget the
    # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
    # # fonts?
    # (pkgs.nerdfonts.override { fonts = [ "FantasqueSansMono" ]; })

    # # You can also create simple shell scripts directly inside your
    # # configuration. For example, this adds a command 'my-hello' to your
    # # environment:
    # (pkgs.writeShellScriptBin "my-hello" ''
    #   echo "Hello, ${config.home.username}!"
    # '')
  ];

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
  };

  # Home Manager can also manage your environment variables through
  # 'home.sessionVariables'. These will be explicitly sourced when using a
  # shell provided by Home Manager. If you don't want to manage your shell
  # through Home Manager then you have to manually source 'hm-session-vars.sh'
  # located at either
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  ~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/sawyer/etc/profile.d/hm-session-vars.sh
  #
  home.sessionVariables = {
    # EDITOR = "emacs";
  };

  home.shellAliases = importAndMerge ./aliases {};

  programs = {
    home-manager = {
      # Let Home Manager install and manage itself.
      enable = true;
    };
    zsh = {
      enable = true;
      history = {
        append = true;
      };
    };
    bash = {
      enable = true;
    };
    direnv = {
      enable = true;
      enableBashIntegration = true;
      enableZshIntegration = true;
      nix-direnv.enable = true;
    };
    git = {
      enable = true;

      settings = {
        init.defaultBranch = "main";
        user.name = "Sawyer Hopkins";
        user.email = "sawyer@sawyerhopkins.com";
        core.sshCommand = "ssh -i ~/.ssh/id_rsa -o IdentitiesOnly=yes";
        alias = {
          s = "status";
          co = "checkout";
        };
      };

      includes = importAndMerge ./git_includes [];

      signing = {
        format = "ssh";
        key = "~/.ssh/id_rsa";
        signByDefault = true;
      };
    };
  };
}
