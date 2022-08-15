{ nixpkgs ? import /tmp/nixpkgs {} } :
nixpkgs.haskellPackages.callPackage ./myderivation.nix {}
