{
  # Installs Zed (the command is "zeditor") and writes ~/.config/zed/settings.json,
  # which is then read-only: change settings here, not in Zed's UI.
  programs.zed-editor = {
    enable = true;
    # Zed installs these on startup (they are not built by Nix)
    extensions = [ "arduino" "html" "julia" "latex" "lua" "nix" ];
    userSettings = {
      cli_default_open_behavior = "existing_window";
      show_edit_predictions = false;
      bottom_dock_layout = "contained";
      tabs = {
        file_icons = true;
        git_status = true;
      };
      project_panel = {
        git_status_indicator = true;
        diagnostic_badges = true;
        bold_folder_labels = true;
        button = true;
        dock = "left";
      };
      collaboration_panel = {
        button = false;
        dock = "left";
      };
      git_panel = {
        show_count_badge = true;
        entry_primary_click_action = "file_diff";
        file_icons = true;
        tree_view = true;
        dock = "left";
      };
      agent = {
        prevent_idle_sleep = false;
        enable_feedback = false;
        threads_sidebar = {
          auto_open = false;
          position = "right";
        };
        dock = "right";
        favorite_models = [ ];
        model_parameters = [ ];
      };
      status_bar.line_endings_button = true;
      title_bar = {
        show_branch_status_icon = true;
        show_menus = true;
        show_sign_in = false;
      };
      toolbar.code_actions = true;
      edit_predictions = {
        provider = "ollama";
        allow_data_collection = "no";
      };
      agent_servers.claude-acp.type = "registry";
      telemetry = {
        diagnostics = false;
        metrics = false;
        anthropic_retention = false;
      };
      base_keymap = "VSCode";
      vim_mode = true;
      ui_font_size = 16;
      buffer_font_size = 15;
      theme = {
        mode = "system";
        light = "One Light";
        dark = "One Dark";
      };
    };
  };
}
