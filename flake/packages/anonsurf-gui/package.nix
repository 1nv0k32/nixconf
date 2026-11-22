{
  lib,
  stdenv,
  anonsurf,
  cmake,
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
      --replace-fail '"/usr/bin/konsole"' '"konsole"' \
      --replace-fail 'QFileInfo(KonsolePath).isExecutable()' '!QStandardPaths::findExecutable(KonsolePath).isEmpty()' \
      --replace-fail '#include <QJsonObject>' $'#include <QJsonObject>\n#include <QStandardPaths>'
  '';

  meta = {
    description = "Qt interface for AnonSurf";
    longDescription = ''
      Qt 6 interface for managing AnonSurf routing, status, Tor identities
      and startup integration. It controls the `anonsurfd.service` provided by
      `services.anonsurf` and opens the Tor monitor in Konsole when available.
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
