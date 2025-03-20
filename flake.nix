{
  outputs = {
    nixpkgs,
    flake-utils,
    ...
  }:
    flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = import nixpkgs {
          inherit system;
        };
        trackpad-is-too-damn-big = let
          version = "1.0.0";
          pname = "trackpad-is-too-damn-big";
        in (
          with pkgs;
            stdenv.mkDerivation {
              inherit version;
              inherit pname;

              src = fetchFromGitHub {
                owner = "luqmanishere";
                repo = "${pname}";
                rev = "d85fbfc042fd717ee4a62c9bf4ff588ea9fdd009";
                sha256 = "XLNk4FfTmVCv99uJhv2VWOf8hXOchSV330832pOvI3Y=";
              };
              nativeBuildInputs = [
                clang
                cmake
                pkg-config
              ];
              buildInputs = [libevdev];
              buildPhase = "make -j $NIX_BUILD_CORES";
              installPhase = ''
                runHook preInstall
                mkdir -p $out/bin
                mv $TMP/source/build/titdb $out/bin
                runHook postInstall
              '';

              meta = with lib; {
                description = "A customizable utility that allows Linux users to change trackpad behaviour";
                license = licenses.gpl3Only;
                platforms = platforms.linux;
                mainProgram = "titdb";
              };
            }
        );
      in rec {
        defaultApp = flake-utils.lib.mkApp {
          drv = defaultPackage;
          name = "titdb";
        };
        defaultPackage = trackpad-is-too-damn-big;
        devShell = pkgs.mkShell {
          buildInputs = [trackpad-is-too-damn-big];
        };
      }
    );

  inputs = {
    nixpkgs = {
      url = "github:nixos/nixpkgs/nixos-unstable";
    };
    flake-utils = {
      url = "github:numtide/flake-utils";
    };
  };
}
