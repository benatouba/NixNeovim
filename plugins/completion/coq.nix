{ pkgs, lib, config, ... }:
with lib;
let
  cfg = config.programs.nixvim.plugins.coq-nvim;
  helpers = import ../helpers.nix { inherit lib pkgs config; };
in {
  options = {
    programs.nixvim.plugins.coq-nvim = {
      enable = mkEnableOption "Enable coq-nvim";

      installArtifacts = mkEnableOption "Install coq-artifacts";

      autoStart = mkOption {
        type = with types; nullOr (oneOf [ bool (enum [ "shut-up" ]) ]);
        default = null;
        description = "Auto-start or shut up";
      };

      recommendedKeymaps = mkOption {
        type = with types; nullOr bool;
        default = null;
        description = "Use the recommended keymaps";
      };
    };
  };
  config = let
    settings = {
      auto_start = cfg.autoStart;
      "keymap.recommended" = cfg.recommendedKeymaps;
    };
  in mkIf cfg.enable {
    programs.nixvim = {
      extraPlugins = [
        # plugins.coq-nvim
        pkgs.vimExtraPlugins.coq-nvim
      ] ++ optional cfg.installArtifacts pkgs.vimExtraPlugins.coq-artifacts;
      plugins.lsp = {
        preConfig = ''
          vim.g.coq_settings = ${helpers.toLuaObject settings}
        '';
        coqSupport = true;
      };
    };
  };
}
