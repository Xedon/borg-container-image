{
  description = "Container build of borg for multiple platforms";
  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
  outputs = { self, nixpkgs }:
    let
      supportedSystems = [
        "x86_64-linux"
        "aarch64-linux"
      ];

      # Helper to provide system-specific attributes
      forEachSupportedSystem = f: nixpkgs.lib.genAttrs supportedSystems (system: f {
        pkgs = import nixpkgs { inherit system; };
        architecture = if system == "x86_64-linux" then "amd64" else "arm64";
      });
    in
    {
      packages = forEachSupportedSystem ({ pkgs, architecture }: {
        default = pkgs.dockerTools.buildLayeredImage  {
          name = "ghcr.io/xedon/borg";
          tag = "${pkgs.borgbackup.version}-${architecture}";
          created = "now";
          architecture = architecture;
          contents = with pkgs.dockerTools; [
            fakeNss
            pkgs.borgbackup
            pkgs.coreutils
          ];
          config.Entrypoint = [ "${pkgs.borgbackup}/bin/borg" ];
        };
      });
    };
}