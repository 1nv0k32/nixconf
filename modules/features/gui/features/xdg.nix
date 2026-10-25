{ lib, pkgs, ... }:
let
  mimeTypes = {
    "chromium-browser.desktop" = [
      "x-scheme-handler/http"
      "x-scheme-handler/https"
    ];
    "org.gnome.Nautilus.desktop" = [ "inode/directory" ];
    "org.gnome.Evince.desktop" = [ "application/pdf" ];
    "org.gnome.eog.desktop" = map (type: "image/${type}") [
      "bmp"
      "gif"
      "jpg"
      "pjpeg"
      "png"
      "tiff"
      "webp"
      "x-bmp"
      "x-gray"
      "x-icb"
      "x-ico"
      "x-png"
      "x-portable-anymap"
      "x-portable-bitmap"
      "x-portable-graymap"
      "x-portable-pixmap"
      "x-xbitmap"
      "x-xpixmap"
      "x-pcx"
      "svg+xml"
      "svg+xml-compressed"
      "vnd.wap.wbmp"
      "x-icns"
    ];
    "vlc.desktop" = map (type: "video/${type}") [
      "x-ogm+ogg"
      "3gp"
      "3gpp"
      "3gpp2"
      "dv"
      "divx"
      "fli"
      "flv"
      "mp2t"
      "mp4"
      "mp4v-es"
      "mpeg"
      "mpeg-system"
      "msvideo"
      "ogg"
      "quicktime"
      "vivo"
      "vnd.divx"
      "vnd.mpegurl"
      "vnd.rn-realvideo"
      "vnd.vivo"
      "webm"
      "x-anim"
      "x-avi"
      "x-flc"
      "x-fli"
      "x-flic"
      "x-flv"
      "x-m4v"
      "x-matroska"
      "x-mjpeg"
      "x-mpeg"
      "x-mpeg2"
      "x-ms-asf"
      "x-ms-asf-plugin"
      "x-ms-asx"
      "x-msvideo"
      "x-ms-wm"
      "x-ms-wmv"
      "x-ms-wmx"
      "x-ms-wvx"
      "x-nsv"
      "x-theora"
      "x-theora+ogg"
      "x-ogm"
      "avi"
      "x-mpeg-system"
    ];
  };
  associations = lib.concatMapAttrs (app: types: lib.genAttrs types (_: [ app ])) mimeTypes;
in
{
  environment.systemPackages = with pkgs; [
    nautilus
    evince
    eog
    vlc
  ];

  xdg.mime = {
    enable = true;
    addedAssociations = associations;
    defaultApplications = associations;
  };
}
