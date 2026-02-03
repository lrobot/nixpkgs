{
  lib,
  stdenv,
  fetchurl,
}:

stdenv.mkDerivation rec {
  pname = "xtensa-esp32-elf";
  version = "15.2.0_20251204";

  suffix =
    {
      x86_64-linux = "x86_64-linux-gnu";
      x86_64-darwin = "x86_64-apple-darwin";
      aarch64-darwin = "aarch64-apple-darwin";
      aarch64-linux = "aarch64-linux-gnu";
      i686-windows = "i686-w64-mingw32";
    }
    .${stdenv.hostPlatform.system} or (throw "Unsupported system: ${stdenv.hostPlatform.system}");

  src = fetchurl {
    url = "https://github.com/espressif/crosstool-NG/releases/download/esp-${version}/xtensa-esp-elf-${version}-${suffix}.tar.xz";
    hash =
      {
        x86_64-linux = "sha256:3d50f5cd5f173acfd524e07c1cd69bc99585731a415ca2e5bce879997fe602b8";
        x86_64-darwin = "sha256:96da1fcf01e2ac89819d1e336ca9e27762c35ea120627b89de8fd482f42c54f8";
        aarch64-darwin = "sha256:68d3fb1e75c6bb1b88c6a2c74977abd51efd09b560a99149bafdcf403cb21941";
        aarch64-linux = "sha256:c8a8255009803036ba3def98a97a7134ee5a8ac5db048425e126fcf07f27ce1c";
        i686-windows = "sha256:72403f48827f75495f7c0b1c2be9f643c8dac25af7722545fc3ba1f21e834389";
      }
        .${stdenv.hostPlatform.system} or (throw "Unsupported system: ${stdenv.hostPlatform.system}");
  };

  phases = [ "unpackPhase" "installPhase" ];

  installPhase = ''
    cp -r . $out
    find $out -type f | while read f; do
      patchelf "$f" > /dev/null 2>&1 || continue
      patchelf --set-interpreter $(cat ${stdenv.cc}/nix-support/dynamic-linker) "$f" || true
      patchelf --set-rpath ${
        lib.makeLibraryPath [
          "$out"
          stdenv.cc.cc
        ]
      } "$f" || true
    done
  '';

  meta = with lib; {
    description = "Pre-built https://github.com/espressif/crosstool-NG";
    homepage = "https://github.com/espressif/crosstool-NG";
    license = with licenses; [
      bsd2
      gpl2
      gpl3
      lgpl21
      lgpl3
      mit
    ];
    platforms = [
      "x86_64-linux"
      "x86_64-darwin"
      "aarch64-darwin"
      "aarch64-linux"
      "i686-linux"
    ];
    sourceProvenance = with sourceTypes; [ binaryNativeCode ];
  };
}
