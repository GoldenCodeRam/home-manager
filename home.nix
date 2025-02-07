{ config, pkgs, lib, ... }:

{
  # manage.
  home.username = "goldencoderam";
  home.homeDirectory = "/home/goldencoderam";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "24.11"; # Please read the comment before changing.

  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
    "ngrok"
    "android-studio-stable"
  ];

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = [
    # # Adds the 'hello' command to your environment. It prints a friendly
    # # "Hello, world!" when run.
    # pkgs.hello

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
    pkgs.devenv

    # Clipboard utility for Vim.
    pkgs.xclip
    pkgs.picom

    pkgs.p7zip

    # Tmux session management.
    pkgs.sesh
    pkgs.tree-sitter

    # Keyboard remapping
    pkgs.kanata

    # These are mine.
    pkgs.netcat

    pkgs.android-studio
    pkgs.flutter

    pkgs.dbeaver-bin

    # These are for work.
    pkgs.ngrok
    pkgs.openvpn
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
  #  /etc/profiles/per-user/goldencoderam/etc/profile.d/hm-session-vars.sh
  #
  home.sessionVariables = {
    # EDITOR = "emacs";
    
    # Android Studio related configuration.
    ANDROID_HOME="$HOME/Android/Sdk";
  };

  home.shellAliases = {
    tsl = "sesh connect $(sesh list | fzf)";
  };


  # Creates the Kanata service.
  systemd.user.services.kanata = {
    Unit = {
      Description = "Tool to improve keyboard comfort and usability with advanced customization.";
    };
    Install = {
      WantedBy = [ "default.target" ];
    };
    Service = {
      ExecStart = ''
        ${pkgs.kanata}/bin/kanata $HOME/.config/kanata/kanata.kbd
      '';
    };
  };

  programs = {
    # Let Home Manager install and manage itself.
    home-manager.enable = true;

    htop.enable = true;

    fzf = {
      enable = true;

      enableZshIntegration = true;
      tmux.enableShellIntegration = true;
    };

    java = {
      enable = true;
      package = pkgs.jdk17;
    };

    direnv = {
      enable = true;
      enableZshIntegration = true;
      nix-direnv.enable = true;
    };

    zsh = {
      enable = true;

      enableCompletion = true;
      syntaxHighlighting.enable = true;
      autosuggestion.enable = true;

      historySubstringSearch = {
        enable = true;

        searchUpKey = "^p";
        searchDownKey = "^n";
      };

      antidote = {
        enable = true;
        plugins = [
          "Aloxaf/fzf-tab"
        ];
      };

      # Android Studio related configuration.
      initExtra = ''
        export PATH=$PATH:$ANDROID_HOME/emulator
        export PATH=$PATH:$ANDROID_HOME/platform-tools
        export PATH=$PATH:$ANDROID_HOME/cmdline-tools/latest/bin
        zstyle ':completion:*' menu no
        zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'
        bindkey '^y' autosuggest-accept
      '';
    };

    oh-my-posh = {
      enable = true;

      enableZshIntegration = true;
      settings = builtins.fromJSON(''
        {
          "version": 2,
          "final_space": true,
          "console_title_template": "{{ .Shell }} in {{ .Folder }}",
          "transient_prompt": {
            "background": "transparent",
            "foreground_templates": [
              "{{ if gt .Code 0 }}red{{ end }}",
              "{{ if eq .Code 0 }}magenta{{ end }}"
            ],
            "template": "❯ "
          },
          "secondary_prompt": {
            "background": "magenta",
            "foreground": "transparent",
            "template": "❯❯ "
          },
          "blocks": [
            {
              "type": "prompt",
              "alignment": "left",
              "newline": true,
              "segments": [
                {
                  "type": "path",
                  "style": "plain",
                  "background": "transparent",
                  "foreground": "blue",
                  "template": "{{ .Path }}",
                  "properties": {
                    "style": "full"
                  }
                },
                {
                  "type": "git",
                  "style": "plain",
                  "background": "transparent",
                  "foreground": "gray",
                  "template": " {{ .HEAD }}{{ if or (.Working.Changed) (.Staging.Changed) }}*{{ end }} <cyan>{{ if gt .Behind 0 }}{{ end }}{{ if gt .Ahead 0 }}{{ end }}",
                  "properties": {
                    "branch_icon": "",
                    "commit_icon": "@",
                    "fetch_status": true
                  }
                }
              ]
            },
            {
              "type": "rprompt",
              "overflow": "hidden",
              "segments": [ 
                {
                  "type": "executiontime",
                  "style": "plain",
                  "background": "transparent",
                  "foreground": "yellow",
                  "template": "{{ .FormattedMs }}",
                  "properties": {
                    "threshold": 5000
                  }
                } 
              ]
            },
            {
              "type": "prompt",
              "alignment": "left",
              "newline": true,
              "segments": [
                {
                  "type": "text",
                  "style": "plain",
                  "background": "transparent",
                  "foreground_templates": [
                    "{{ if gt .Code 0 }}red{{ end }}",
                    "{{ if eq .Code 0 }}magenta{{ end }}"
                  ],
                  "template": "❯"
                }
              ]
            }
          ]
        }
      '');
    };

    lazygit.enable = true;

    feh.enable = true;

    zoxide.enable = true;

    tmux = {
      enable = true;
      shell = "${pkgs.zsh}/bin/zsh";
      baseIndex = 1;
      prefix = "C-Space";
      keyMode = "vi";

      plugins = with pkgs; [
        tmuxPlugins.fingers
      ];

      extraConfig = ''
        # Base config
        set -g renumber-windows on

        # Statusbar
        set -g status-position top

        ## COLORSCHEME: everforest
        set -g status-style 'bg=#272E33'
        set -g status-right ""

        # Don't exit from tmux when closing a session
        set -g detach-on-destroy off

        # moving between panes with vim movement keys
        bind h select-pane -L
        bind j select-pane -D
        bind k select-pane -U
        bind l select-pane -R

        # Kill panel
        bind-key "q" detach
        # Kill session
        bind-key "Q" kill-session

        # Sesh configuration
        bind-key "K" run-shell "sesh connect $(sesh list | fzf-tmux -p 55%,60%)"
      '';
    };
  };
}
