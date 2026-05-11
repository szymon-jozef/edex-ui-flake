{
  description = "eDEX-ui flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs =
    {
      nixpkgs,
      ...
    }:

    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };

      pname = "edex-ui";
      version = "2.2.8";
      edexSrc = pkgs.fetchurl {
        url = "https://github.com/GitSquared/edex-ui/releases/download/v2.2.8/eDEX-UI-Linux-x86_64.AppImage";
        hash = "sha256-yPKM1yHKAyygwZYLdWyj5k3EQaZDwy6vu3nGc7QC1oE=";
      };

      appimageContents = pkgs.appimageTools.extractType2 {
        inherit pname version;
        src = edexSrc;
      };

      edexPkg = pkgs.appimageTools.wrapType2 {
        inherit pname version;
        src = edexSrc;

        extraPkgs =
          pkgs: with pkgs; [
            libxshmfence
          ];

        extraInstallCommands = ''
          install -m 444 -D ${appimageContents}/edex-ui.desktop $out/share/applications/edex-ui.desktop
          install -m 444 -D ${appimageContents}/edex-ui.png $out/share/icons/hicolor/512x512/apps/edex-ui.png
          substituteInPlace $out/share/applications/edex-ui.desktop --replace 'Exec=AppRun' 'Exec=${pname}'
        '';
      };
    in
    {
      packages.${system}.default = edexPkg;

      apps.${system}.default = {
        type = "app";
        program = "${edexPkg}/bin/${pname}";
      };
    };
}
