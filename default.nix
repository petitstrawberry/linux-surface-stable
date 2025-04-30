{ pkgs ? import <nixpkgs> {} }:

let
  version = "6.14.2";
  rev = "surface-linux-${version}";
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

  inherit (pkgs.callPackage ./kernel/linux-package.nix { inherit repos; }) linuxPackage surfacePatches;

  kernelPatches = surfacePatches {
    version = version;
    patchFn = ./kernel/6.14/patches.nix;
  };

  surfaceKernel = linuxPackage {
    inherit version kernelPatches;
    sha256 = srcSha256;
    ignoreConfigErrors = true;
  };

in {
  linux-surface-6_14_2 = surfaceKernel;
  linux-surface-stable = surfaceKernel;
}
