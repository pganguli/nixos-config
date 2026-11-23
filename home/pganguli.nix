{ config, pkgs, ... }: {
  imports = [ ./plasma.nix ./plasma-panel.nix ./plasma-apps.nix ./mime.nix ./zed.nix ./vesktop.nix ./firefox.nix ./thunderbird.nix ./zotero.nix ];

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

    # Python for programs installed from PyPI (wheels): uv's own builds, which
    # run through nix-ld (modules/system/nix.nix). Nix's Python can't find the
    # shared libraries that wheels expect. Plain "python3" stays Nix's.
    # Needs: uv python install 3.12
    UV_PYTHON_PREFERENCE = "only-managed";
    PIPX_DEFAULT_PYTHON = "$HOME/.local/share/uv/python/cpython-3.12-linux-x86_64-gnu/bin/python3.12";
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
        gpgsign = true;    # sign with the SSH key (user.signingkey), through ssh-agent
        verbose = true;
      };
      tag.gpgsign = true;
      gpg.format = "ssh";
      gpg.ssh.allowedSignersFile = "/home/pganguli/.ssh/allowed_signers";   # to verify signatures
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

  # GitHub CLI. Run "gh auth login" once. git keeps using SSH keys (see the
  # url.insteadOf entries above), so gh must not take over the credential helper.
  programs.gh = {
    enable = true;
    gitCredentialHelper.enable = false;
    settings.git_protocol = "ssh";
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
      keyboard.bindings = [
        # Shift+Enter sends ESC + CR (Nix has no \u escape, so fromJSON makes the ESC character)
        { key = "Return"; mods = "Shift"; chars = builtins.fromJSON ''"\u001b\r"''; }
      ];
    };
  };

  # virt-manager: connect to the system libvirt daemon on start (the window
  # sizes and column choices it also stores in dconf are UI state, not listed)
  dconf.settings."org/virt-manager/virt-manager/connections" = {
    autoconnect = [ "qemu:///system" ];
    uris = [ "qemu:///system" ];
  };

  # IBus (engine installed in modules/system/locale.nix): the settings made in
  # ibus-setup and the Typing Booster preferences window. The "version" key
  # that IBus writes itself is not listed.
  dconf.settings = {
    "desktop/ibus/general" = {
      engines-order = [ "xkb:us::eng" "typing-booster" ];
      preload-engines = [ "xkb:us::eng" "typing-booster" ];
      use-system-keyboard-layout = true;
    };
    "desktop/ibus/general/hotkey".triggers = [ "<Super>space" ];
    "desktop/ibus/panel/emoji".has-partial-match = true;
    "org/freedesktop/ibus/engine/typing-booster" = {
      addspaceoncommit = true;
      aichatenable = false;
      autocapitalize = true;
      autoselectcandidate = 2;
      dictionary = "en_US";
      disableinterminals = true;
      ibuskeymap = "us";
      inlinecompletion = 1;
      inputmethod = "NoIME";
      mincharcomplete = 2;
      showfinalform = true;
      tabenable = true;
      wordpredictions = true;
    };
  };

  # pass: the store is a private git repo, cloned by hand on a new machine:
  #   git clone git@github.com:pganguli/password-store.git ~/.password-store
  # (entries are encrypted to the GPG key in its .gpg-id; gpg-agent and the Qt
  # pinentry are set up in modules/system/security.nix). PassFF's native host
  # is in home/firefox.nix.
  # Extensions: "pass otp" (one-time codes) and "pass audit" (weak, reused and
  # leaked passwords).
  programs.password-store = {
    enable = true;
    package = pkgs.pass.withExtensions (exts: [ exts.pass-otp exts.pass-audit ]);
    settings.PASSWORD_STORE_DIR = "${config.home.homeDirectory}/.password-store";
  };

  # ---------- SSH ----------
  # Client config from the old dotfiles: ~/.ssh/config includes ~/.ssh/config.d/*
  home.file.".ssh/config".source = ./files/ssh/config;
  home.file.".ssh/config.d" = {
    source = ./files/ssh/config.d;
    recursive = true;
  };

  # Tell every program in the Plasma session where the agent is. NixOS sets
  # SSH_AUTH_SOCK only when XDG_RUNTIME_DIR already exists while it builds the
  # login environment, which is not the case for the SDDM Wayland session, so
  # terminals, ssh and git did not see the agent and asked for the passphrase.
  xdg.configFile."plasma-workspace/env/ssh-agent.sh".text = ''
    export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/ssh-agent"
  '';

  # Load the SSH key into ssh-agent after login. ksshaskpass reads the
  # passphrase from KWallet; the first time, it asks and offers to remember it.
  systemd.user.services.ssh-add-keys = {
    Unit = {
      Description = "Add SSH keys to ssh-agent";
      After = [ "graphical-session.target" "ssh-agent.service" ];
      Requires = [ "ssh-agent.service" ];
      PartOf = [ "graphical-session.target" ];
    };
    Service = {
      Type = "oneshot";
      Environment = [
        "SSH_AUTH_SOCK=%t/ssh-agent"
        "SSH_ASKPASS=${pkgs.kdePackages.ksshaskpass}/bin/ksshaskpass"
        "SSH_ASKPASS_REQUIRE=force"
      ];
      ExecStart = "${pkgs.openssh}/bin/ssh-add %h/.ssh/ssh_ed25519";
    };
    Install.WantedBy = [ "graphical-session.target" ];
  };

  # ---------- Files from the old dotfiles ----------
  programs.tmux = {
    enable = true;
    shell = "${pkgs.fish}/bin/fish";   # tmux starts fish directly
    sensibleOnTop = false;             # tmux.conf already sets what it needs
    extraConfig = builtins.readFile ./files/tmux.conf;
  };

  # vifm: only the scripts are linked, so vifm can still write vifminfo.json
  programs.vifm = {
    enable = true;
    extraConfig = builtins.readFile ./files/vifm/vifmrc;
  };
  xdg.configFile."vifm/scripts" = {
    source = ./files/vifm/scripts;
    recursive = true;
  };

  programs.neovim = {
    enable = true;
    defaultEditor = true;   # sets EDITOR=nvim
    viAlias = true;         # "vi" opens nvim
    vimAlias = true;        # "vim" opens nvim
    sideloadInitLua = true; # keep Home Manager from writing init.lua into the linked config dir
  };
  # Neovim config: a writable link to the repo, so vim.pack can write nvim-pack-lock.json
  xdg.configFile."nvim".source =
    config.lib.file.mkOutOfStoreSymlink "/home/pganguli/.config/nixos/home/files/nvim";

  # Personal scripts
  home.file.".local/bin" = {
    source = ./files/bin;
    recursive = true;
  };

  programs.mpv = {
    enable = true;
    config = {
      hwdec = "yes";
      save-position-on-quit = "yes";
    };
  };

  programs.zathura = {
    enable = true;
    options = {
      incremental-search = true;
      selection-clipboard = "clipboard";
      synctex = true;
      synctex-editor-command = "zeditor %{input}:%{line}";
    };
  };

  # Claude Code: the command is "claude"; Nix updates it, not its own updater.
  # settings.json is generated from "settings" and read-only, so add new
  # settings (permissions, env, hooks, ...) here, not with /config or by
  # approving a permission prompt permanently.
  programs.claude-code = {
    enable = true;
    settings = {
      theme = "dark";
    };
  };

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
