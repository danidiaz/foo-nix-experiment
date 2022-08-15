# remember to point nixpkgs to the right fork and the right branch
# https://github.com/danidiaz/nixpkgs/tree/haskell_avoid_recomp_experiment 
{ nixpkgs ? import /tmp/nixpkgs {} } :
nixpkgs.haskellPackages.callPackage ./myderivation.nix {}
