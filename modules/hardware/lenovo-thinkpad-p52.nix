_:
{
  flake.modules.nixos.hardware-lenovo-thinkpad-p52 = _: {
    services.thinkfan.enable = true;
  };
}
