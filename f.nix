{
  description = "A julia dev flake";

  inputs = {nixpkgs.url = "nixpkgs/nixos-unstable";};

  outputs = {
    self,
    nixpkgs,
  }: let
    supportedSystems = ["x86_64-linux"];
    forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
    pkgs = forAllSystems (system: import nixpkgs {inherit system;});
    fhs_julia = system:
      pkgs.${system}.buildFHSUserEnv {
        name = "julia-env";
        targetPkgs = pkgs: (with pkgs; [julia gcc zlib]);
        runScript = "bash";
      };
  in {
    devShells = forAllSystems (system: {
      default = {};
      fhs = (fhs_julia system).env;
    });
  };
}
