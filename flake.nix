{
  outputs = {nixpkgs, ...}: let
    pkgs = import nixpkgs {system = "x86_64-linux";};
  in {
    nixosModules.default = import ./scientific-nix/module.nix;
    packages.x86_64-linux.scientific-fhs = pkgs.callPackage ./scientific_nix/fhs.nix {
      enableNVIDIA = false;
      enableGraphical = true;
      juliaVersion = "1.11.5";
    };
  };
}
