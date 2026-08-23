_: {
  # Basic Terraform user configuration and plugin cache setup
  home.file = {
    ".terraformrc" = {
      text = ''
        plugin_cache_dir = "$HOME/.terraform.d/plugin-cache"
      '';
      mode = "0644";
    };

    # Ensure plugin-cache directory exists (placeholder file)
    ".terraform.d/plugin-cache/.keep" = {
      text = "";
    };
  };

  # Make Terraform plugin cache available in session env
  home.sessionVariables = {
    TF_PLUGIN_CACHE_DIR = "$HOME/.terraform.d/plugin-cache";
  };
}
