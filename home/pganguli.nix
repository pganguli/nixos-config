{ config, pkgs, ... }: {
  # Do not change
  home.stateVersion = "26.05";

  # ---------- Environment ----------
  home.sessionPath = [
    "$HOME/.local/bin"
    "$HOME/.cargo/bin"   # programs installed with "cargo install"
    "$HOME/.go/bin"      # programs installed with "go install"
    "$HOME/ti/gcc/bin"   # TI GCC toolchain, if installed
  ];
  home.sessionVariables = {
    VISUAL = "nvim";
    TERMINAL = "alacritty";
    MANWIDTH = "80";
    GOPATH = "$HOME/.go";
  };

  # ---------- Git ----------
  programs.git = {
    enable = true;
    package = pkgs.gitFull;   # includes the libsecret credential helper
    lfs.enable = true;
    ignores = [ "CLAUDE.md" "**/.claude/" ];
    settings = {
      user = {
        name = "Prateek Ganguli";
        email = "prateek.ganguli@gmail.com";
        signingkey = "/home/pganguli/.ssh/ssh_ed25519.pub";
      };
      core.editor = "nvim";
      init.defaultBranch = "main";
      alias = {
        ap = "add --patch";
        big = "!git rev-list --objects --all | git cat-file --batch-check='%(objecttype) %(objectname) %(objectsize:disk) %(rest)' | awk '/^blob/ {print $3, $4}' | sort -rn | numfmt --to=iec-i --suffix=B --padding=10 --field=1 | column -t";
        big-lfs = "!git lfs ls-files --size --all | awk '{gsub(/[()]/, \"\"); print $(NF-1) $NF, $3}' | sort -rh | column -t";
        bm = "branch --move --force";
        br = "branch";
        brh = "!f() { git branch --force \"$1\" HEAD; }; f";
        cb = "checkout -b";
        ci = "commit";
        cia = "commit --amend";
        co = "checkout";
        di = "diff";
        discard = "!echo -n 'Remove all untracked files? [y/N]: ' && read 'x' && [ $x = 'y' ] && git checkout --force && git clean -d --interactive";
        dl = "diff HEAD~1";
        ds = "diff --staged";
        ignore = "!git update-index --assume-unchanged";
        ignored = "!git ls-files -v |grep ^[a-z]";
        lg = "log --oneline --decorate --graph --all";
        ll = "log -1 HEAD --stat";
        lo = "log --oneline --decorate";
        lp = "log --patch";
        ls = "ls-tree --full-tree --name-only -r HEAD";
        mxt = "merge -X theirs";
        pu = "push";
        puo = "push --set-upstream origin";
        rao = "remote add origin";
        rau = "remote add upstream";
        re = "checkout --";
        ri = "rebase --interactive";
        rir = "rebase --interactive --root";
        rsuo = "remote set-url origin";
        sc = "switch --create";
        st = "status";
        subu = "submodule update --init --recursive";
        sw = "switch";
        unignore = "!git update-index --no-assume-unchanged";
        unstage = "reset HEAD --";
      };
      commit = {
        gpgsign = false;   # turn on in the security phase, after the SSH key is on this laptop
        verbose = true;
      };
      gpg.format = "ssh";
      push = {
        default = "simple";
        autoSetupRemote = true;
      };
      pull.ff = "only";
      diff.algorithm = "histogram";
      merge = {
        ff = "no";
        commit = "no";
        tool = "nvimdiff2";
        conflictstyle = "zdiff3";
      };
      mergetool.keepBackup = false;
      rerere.enabled = true;
      url."git@github.com:".insteadOf = "https://github.com/";
      url."git@salsa.debian.org:".insteadOf = "https://salsa.debian.org/";
      url."git@es-git.cs.uni-tuebingen.de:".insteadOf = "https://es-git.cs.uni-tuebingen.de/";
      color.ui = "auto";
      credential.helper = "libsecret";
      safe.directory = "/workspace";
    };
  };

  # ---------- Fish ----------
  programs.fish = {
    enable = true;
    plugins = [
      { name = "pure"; src = pkgs.fishPlugins.pure.src; }   # Pure prompt, as in zsh
    ];
    interactiveShellInit = ''
      set -g fish_greeting                      # no greeting message
      fish_vi_key_bindings                      # vi mode
      set -g pure_symbol_prompt '$'
      set -g pure_symbol_reverse_prompt ':'     # symbol in vi normal mode
      set -g pure_threshold_command_duration 1  # show duration of commands over 1 s
    '';
    functions = {
      rmdempty = {
        description = "Delete empty directories";
        body = ''
          if test (count $argv) -ne 1
            echo "Usage: rmdempty <path>" >&2
            return 1
          end
          find $argv[1] -empty -type d -delete
        '';
      };
      rscp = {
        description = "rsync wrapper";
        body = ''
          rsync --archive --compress --human-readable --verbose --partial --progress --modify-window=1 (string trim --right --chars=/ -- $argv)
        '';
      };
      ring_bell = {
        description = "Ring the bell before each prompt";
        onEvent = "fish_prompt";
        body = "printf '\\a'";
      };
    };
    shellAbbrs = {
      wifi-rescan = "nmcli device wifi list --rescan yes";
    };
  };

  # fzf: Ctrl+R history, Ctrl+T files, Alt+C cd
  programs.fzf.enable = true;

  # direnv with nix-direnv: loads a project's Nix devShell when you cd into it
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  # ---------- Alacritty ----------
  programs.alacritty = {
    enable = true;
    settings = {
      env.TERM = "xterm-256color";
      terminal.shell.program = "${pkgs.fish}/bin/fish";
      window = {
        decorations = "full";
        dynamic_title = true;
      };
      scrolling.history = 65536;
      cursor.style = {
        shape = "Block";
        blinking = "Always";
      };
      # Solarized Light
      colors = {
        primary = {
          foreground = "#073642";
          background = "#fdf6e3";
        };
        normal = {
          black = "#073642"; red = "#dc322f"; green = "#859900"; yellow = "#b58900";
          blue = "#268bd2"; magenta = "#d33682"; cyan = "#2aa198"; white = "#eee8d5";
        };
        bright = {
          black = "#002b36"; red = "#cb4b16"; green = "#586e75"; yellow = "#657b83";
          blue = "#839496"; magenta = "#6c71c4"; cyan = "#93a1a1"; white = "#fdf6e3";
        };
      };
      keyboard.bindings = [
        { key = "N"; mods = "Control|Shift"; action = "SpawnNewInstance"; }
        # Shift+Enter sends ESC + CR (Nix has no \u escape, so fromJSON makes the ESC character)
        { key = "Return"; mods = "Shift"; chars = builtins.fromJSON ''"\u001b\r"''; }
      ];
    };
  };

  # ---------- Files from the old dotfiles ----------
  # tmux (fish as default shell comes from /etc/tmux.conf)
  xdg.configFile."tmux/tmux.conf".source = ./files/tmux.conf;

  # vifm: link each file, so vifm can still write vifminfo.json in the folder
  xdg.configFile."vifm" = {
    source = ./files/vifm;
    recursive = true;
  };

  # Neovim: a writable link to the repo, so vim.pack can write nvim-pack-lock.json
  xdg.configFile."nvim".source =
    config.lib.file.mkOutOfStoreSymlink "/home/pganguli/.config/nixos/home/files/nvim";

  # Personal scripts
  home.file.".local/bin" = {
    source = ./files/bin;
    recursive = true;
  };

  xdg.configFile."mpv/mpv.conf".text = ''
    hwdec
    save-position-on-quit
  '';

  xdg.configFile."zathura/zathurarc".text = ''
    set incremental-search
    set selection-clipboard "clipboard"
    set synctex true
    set synctex-editor-command "zeditor %{input}:%{line}"
  '';

  xdg.configFile."gdb/gdbinit".text = ''
    set history filename ~/.config/gdb/.gdb_history
    set history save on
    set debuginfod enabled on
    set auto-load safe-path /
  '';

  # aria2
  programs.aria2 = {
    enable = true;
    settings = {
      dir = "/home/pganguli/Downloads";
      log = "/home/pganguli/.aria2.log";

      continue = true;
      disk-cache = "32M";
      file-allocation = "falloc";
      http-accept-gzip = true;
      max-concurrent-downloads = 10;
      max-connection-per-server = 10;
      min-split-size = "10M";
      save-session-interval = 60;
      split = 10;

      enable-rpc = false;
      rpc-allow-origin-all = true;
      rpc-listen-port = 6800;

      bt-max-peers = 0;
      bt-save-metadata = true;
      enable-dht6 = true;
      listen-port = 51413;
      peer-agent = "Transmission/2.77";
      peer-id-prefix = "-TR2770-";
      seed-time = 0;
      user-agent = "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:56.0) Gecko/20100101 Firefox/56.0";
    };
  };

  # MATLAB (nix-matlab): where the MathWorks installer puts MATLAB
  xdg.configFile."matlab/nix.sh".text = ''
    INSTALL_DIR=$HOME/.local/opt/matlab
  '';

  home.file.".julia/config/startup.jl".text = ''
    using Pkg

    if Base.JLOptions().project == C_NULL && isfile("Project.toml") && isfile("Manifest.toml")
        Pkg.activate(".")
    end
  '';
}
