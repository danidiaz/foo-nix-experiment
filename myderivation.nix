{ mkDerivationSpecial, base, lib }:
mkDerivationSpecial {
  pname = "foo";
  version = "1.0.0.0";
  src = ./.;
  isLibrary = false;
  isExecutable = true;
  executableHaskellDepends = [ base ];
  license = "unknown";
  mainProgram = "foo";
  enableSeparateDistOutput = true ;
  enableSeparateDistNewstyleOutput = true ;
#  preexistingDist = /nix/store/3dc1frfayw3ywbh1cwws4k4yp6ydkdb7-foo-1.0.0.0-dist ;
#  preexistingDistNewstyle =  /nix/store/aq1izdqx9lji5zwdqqscm9hd81gkc756-foo-1.0.0.0-distNewstyle ;
}
