# https://gist.github.com/wirew0rm/4881987e7549b390c3acd5767f3b8d6a

{ stdenv, fetchgit, fetchurl, writeText, automake, autoconf, aria2, coreutils, curl, cvs, gcc, git, python3, which, bison, flex, gperf, help2man, libtool, ncurses, texinfo, wget, file }:

stdenv.mkDerivation {
  name = "xtensa-esp32-elf";
  version = "1.22.x";
  src = fetchgit {
    url = "https://github.com/espressif/crosstool-NG.git";
  # branch = "xtensa-${version}";
    rev = "6c4433a51e4f2f2f9d9d4a13e75cd951acdfa80c";
    sha256 = "03qg9vb0mf10nfslggmb7lc426l0gxqhfyvbadh86x41n2j6ddg6";
  };

  meta = {
    maintainers = [
      "Alexander Krimm <alex@wirew0rm.de>"
    ];
  };

  nativeBuildInputs = [
    autoconf automake aria2 coreutils curl cvs
    gcc git python3 which file wget
  ];

  # https://unix.stackexchange.com/questions/356232/disabling-the-security-hardening-options-for-a-nix-shell-environment#367990
  hardeningDisable = [ "format" ];

  buildInputs = [
    bison flex gperf help2man libtool ncurses texinfo
  ];

  configurePhase = ''
    ./bootstrap;
    ./configure --enable-local --disable-static PACKAGE_VERSION=crosstool-ng-1.22.0-80-g6c4433a;
    make;
    echo "CT_LOCAL_TARBALLS_DIR=\"\$\{CT_TOP_DIR\}/tars\"" >> ./samples/xtensa-esp32-elf/crosstool.config;
    echo "CT_FORBID_DOWNLOAD=y" >> ./samples/xtensa-esp32-elf/crosstool.config;
    ./ct-ng xtensa-esp32-elf;
    mkdir tars;
  '' +
  toString ( map ( p: "ln -s " + fetchurl { inherit (p) url sha256; } + " ./tars/" + p.name + ";\n" ) [
    {
      name = "gmp-6.0.0a.tar.xz";
      url = "https://gmplib.org/download/gmp/gmp-6.0.0a.tar.xz";
      sha256 = "0r5pp27cy7ch3dg5v0rsny8bib1zfvrza6027g2mp5f6v8pd6mli";
    }{
      name = "mpfr-3.1.3.tar.xz";
      url = "https://ftp.gnu.org/gnu/mpfr/mpfr-3.1.3.tar.xz";
      sha256 = "05jaa5z78lvrayld09nyr0v27c1m5dm9l7kr85v2bj4jv65s0db8";
    }{
      name = "isl-0.14.tar.xz";
      url = "http://isl.gforge.inria.fr/isl-0.14.tar.xz";
      sha256 = "00zz0dcxvbna2fqqqv37sqlkqpffb2js47q7qy7p184xh414y15i";
    }{
      name = "mpc-1.0.3.tar.gz";
      url = "http://ftp.gnu.org/gnu/mpc/mpc-1.0.3.tar.gz";
      sha256 = "1hzci2zrrd7v3g1jk35qindq05hbl0bhjcyyisq9z209xb3fqzb1";
    }{
      name = "expat-2.1.0.tar.gz";
      url = "http://downloads.sourceforge.net/project/expat/expat/2.1.0/expat-2.1.0.tar.gz";
      sha256 = "11pblz61zyxh68s5pdcbhc30ha1b2vfjd83aiwfg4vc15x3hadw2";
    }{
      name = "ncurses-6.0.tar.gz";
      url = "http://ftp.gnu.org/pub/gnu/ncurses/ncurses-6.0.tar.gz";
      sha256 = "0q3jck7lna77z5r42f13c4xglc7azd19pxfrjrpgp2yf615w4lgm";
    }{
      name = "binutils-2.25.1.tar.bz2";
      url = "http://ftp.gnu.org/gnu/binutils/binutils-2.25.1.tar.bz2";
      sha256 = "08lzmhidzc16af1zbx34f8cy4z7mzrswpdbhrb8shy3xxpflmcdm";
    }{
      name = "gcc-5.2.0.tar.bz2";
      url = "http://ftp.gnu.org/gnu/gcc/gcc-5.2.0/gcc-5.2.0.tar.bz2";
      sha256 = "1bccp8a106xwz3wkixn65ngxif112vn90qf95m6lzpgpnl25p0sz";
    }{
      name = "newlib-2.2.0.tar.gz";
      url = "http://mirrors.kernel.org/sources.redhat.com/newlib/newlib-2.2.0.tar.gz";
      sha256 = "1gimncxzq663l4gp8zd89ynfzhk2q802mcaiyjpr2xbkn1ix5bgq";
    }{
      name = "gdb-7.10.tar.xz";
      url = "http://ftp.gnu.org/pub/gnu/gdb/gdb-7.10.tar.xz";
      sha256 = "1a08c9svaihqmz2mm44il1gwa810gmwkckns8b0y0v3qz52amgby";
    }
  ]);

  buildPhase = ''
    ./ct-ng build;
  '';

  installPhase = ''
    cp -avr ./builds/xtensa-esp32-elf/ $out
  '';
}