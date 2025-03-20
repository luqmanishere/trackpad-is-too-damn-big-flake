{
  outputs = inputs @ {flake-parts, ...}:
    flake-parts.lib.mkFlake {inherit inputs;} (top @ {
      config,
      withSystem,
      moduleWithSystem,
      ...
    }: {
      imports = [];
      systems = ["x86_64-linux" "aarch64-linux"];
      perSystem = {
        config,
        pkgs,
        ...
      }: {
        packages.titdb = pkgs.callPackage ./package.nix {};
        packages.default = config.packages.titdb;
      };
      flake.nixosModules.default = {pkgs, ...}: {
        imports = [./nixos-module.nix];
        services.titdb.package = withSystem pkgs.stdenv.hostPlatform.system ({config, ...}: config.packages.default);
      };
    });

  inputs = {
    nixpkgs = {
      url = "github:nixos/nixpkgs/nixos-unstable";
    };
    flake-parts.url = "github:hercules-ci/flake-parts";
  };
}
