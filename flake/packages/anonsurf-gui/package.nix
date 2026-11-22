{
  lib,
  stdenv,
  anonsurf,
  cmake,
  kdePackages,
  qt6,
}:

stdenv.mkDerivation {
  pname = "anonsurf-gui";
  inherit (anonsurf) version src;

  cmakeDir = "../gui";

  nativeBuildInputs = [
    cmake
    qt6.wrapQtAppsHook
  ];

  buildInputs = [
    qt6.qtbase
    qt6.qtdeclarative
  ];

  cmakeFlags = [ (lib.cmakeFeature "ANONSURF_VERSION" anonsurf.version) ];

  postPatch = ''
    substituteInPlace gui/src/cli/commandclient.cpp \
      --replace-fail '"/usr/bin/anonsurf"' '"${lib.getExe anonsurf}"' \
      --replace-fail '"/usr/lib/anonsurf/safekill"' '"${anonsurf}/lib/anonsurf/safekill"' \
      --replace-fail '"/usr/bin/konsole"' '"${lib.getExe kdePackages.konsole}"'
  '';

  meta = {
    description = "Qt interface for AnonSurf";
    longDescription = ''
      Qt 6 interface for managing AnonSurf routing, status, Tor identities
      and startup integration. It controls the `anonsurfd.service` provided by
      `services.anonsurf` and opens the Tor monitor in Konsole.
    '';
    inherit (anonsurf.meta) homepage maintainers platforms;
    license = with lib.licenses; [
      gpl3Plus
      # Lucide/Feather icon geometry
      isc
      mit
    ];
    mainProgram = "anonsurf-gui";
  };
}
