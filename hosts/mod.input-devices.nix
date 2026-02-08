_:
{
  # Copied from
  # https://github.com/dguibert/nix-config/blob/master/modules/nixos/conf-kanata.nix
  services.kanata = {
    enable = true;
    keyboards.internalKeyboard = {
      extraDefCfg = "process-unmapped-keys yes";
      config = ''
        (defvar
          tap-time 150
          hold-time 200
        )
        (defalias
          caps (tap-hold 200 200 esc lctl)
        )
        (defsrc
          caps
        )
        (deflayer base
          @caps
        )
      '';
    };
  };
}
