{ sources ? import ./nix/sources.nix
, pkgs ? import sources.nixpkgs {}
, inShell ? null
}:

let

  haskellDeps = ps: with ps; [
    base
    shake
  ];

  ghc = pkgs.haskellPackages.ghcWithPackages haskellDeps;

  fontsConf = pkgs.makeFontsConf {
    fontDirectories = [
      pkgs.dejavu_fonts
      pkgs.lora
    ];
  };

  deps = with pkgs; [
    pandoc
    pandoc-include
    haskellPackages.pandoc-crossref
    typst
    shake
    ghc ghcid hlint
    entr
  ];

  env = pkgs.mkShell {
    buildInputs = deps ++ [
    ];
    shellHook = ''
      export FONTCONFIG_FILE="${fontsConf}"
    '';
  };

  # TODO
  drv = pkgs.mkShell {
  };

in if inShell == false
   then drv
   else if pkgs.lib.inNixShell then env else drv
