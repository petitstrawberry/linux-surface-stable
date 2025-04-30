{
  description = "Linux Surface Kernel Flake";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";

  outputs = { self, nixpkgs }: {
    packages.x86_64-linux = let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };

      version = "6.14.2";
      srcSha256 = "sha256-xcaCo1TqMZATk1elfTSnnlw3IhrOgjqTjhARa1d6Lhs=";
      pkgSha256 = "sha256-Pzn+C52TtDcqDVepM5z2cVNCsnRDy0Wwn+FLwgsuicQ=";

      repos = {
        linux-surface = pkgs.fetchFromGitHub {
          owner = "linux-surface";
          repo = "linux-surface";
          rev = "arch-${version}-1";
          sha256 = pkgSha256;
        };
      };

      linuxPkgSet = pkgs.callPackage ./kernel/linux-package.nix { inherit repos; };

      kernelPatches = linuxPkgSet.surfacePatches {
        inherit version;
        patchFn = ./kernel/6.14/patches.nix;
      };

      surfaceKernelSet = linuxPkgSet.linuxPackage {
        inherit version kernelPatches;
        sha256 = srcSha256;
        ignoreConfigErrors = true;
      };
      surfaceKernel = surfaceKernelSet.kernel; # ★ここで「derivation」だけを返す
    in {
      linux-surface-stable = surfaceKernel;
      default = surfaceKernel;
    };
  };
}
