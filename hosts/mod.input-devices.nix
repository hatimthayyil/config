{ ... }:
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
          a (tap-hold $tap-time $hold-time a lmet)
          s (tap-hold $tap-time $hold-time s lalt)
          d (tap-hold $tap-time $hold-time d lsft)
          f (tap-hold $tap-time $hold-time f lctl)
          j (tap-hold $tap-time $hold-time j rctl)
          k (tap-hold $tap-time $hold-time k rsft)
          l (tap-hold $tap-time $hold-time l ralt)
          ; (tap-hold $tap-time $hold-time ; rmet)
        )
        (defsrc
          caps a s d f j k l ;
        )
        (deflayer base
          @caps @a  @s  @d  @f  @j  @k  @l  @;
        )
      '';
    };
  };
}
