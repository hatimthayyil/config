{
  pkgs,
  ...
}: {
  programs.enchant = {
    enable = true;

    ordering = {
      "*" = [ "aspell" "hunspell" "nuspell" ];
      "en" = [ "aspell" ];
    };
  };

  home.packages = with pkgs; [
    languagetool

    # Aspell
    (pkgs.aspellWithDicts (dicts: with dicts; [
      en
      en-computers
      en-science
    ]))
    # Hunspell
    (pkgs.hunspellWithDicts [
      pkgs.hunspellDicts.en_GB-large
      pkgs.hunspellDicts.en_US-large
    ])
    # Nuspell
    (pkgs.nuspellWithDicts [
      pkgs.hunspellDicts.en_GB-large
      pkgs.hunspellDicts.en_US-large
    ])
  ];

  # see https://github.com/minad/jinx/discussions/173
  systemd.user.settings.Manager.DefaultEnvironment = {
    ASPELL_CONF = "dict-dir ${
      pkgs.aspellWithDicts (
        ds: with ds; [
          en
          en-computers
          ar
          ml
        ]
      )
    }/lib/aspell";
  };

  xdg.configFile = {
    # Enchant config
    # NOTE: There seems to be no other way to configure the extra dictionaries
    # for enchant. This setup is rather verbose but this works correctly, and
    # thus will keep it like this for now.
    #"enchant/enchant.ordering".source = ./enchant/enchant.ordering;
    "enchant/hunspell/en_US.aff".source = "${pkgs.hunspellDicts.en_US-large}/share/hunspell/en_US.aff";
    "enchant/hunspell/en_US.dic".source = "${pkgs.hunspellDicts.en_US-large}/share/hunspell/en_US.dic";
    "enchant/hunspell/en_GB.aff".source = "${pkgs.hunspellDicts.en_GB-large}/share/hunspell/en_GB.aff";
    "enchant/hunspell/en_GB.dic".source = "${pkgs.hunspellDicts.en_GB-large}/share/hunspell/en_GB.dic";
    "enchant/aspell/en-computers.rws".source = "${pkgs.aspellDicts.en-computers}/lib/aspell/en-computers.rws";
    "enchant/aspell/en_US-science.rws".source = "${pkgs.aspellDicts.en-science}/lib/aspell/en_US-science.rws";
    "enchant/aspell/en_GB-science.rws".source = "${pkgs.aspellDicts.en-science}/lib/aspell/en_GB-science.rws";
  };
}
