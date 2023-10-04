{
  description = "Intel HPC Kit";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
    shell-utils.url = "github:waltermoreira/shell-utils";
  };

  outputs =
    { self
    , nixpkgs
    , flake-utils
    , shell-utils
    }:

      with flake-utils.lib; eachSystem [
        system.x86_64-linux
      ]
        (system:
        let
          pkgs = import nixpkgs { inherit system; };
          shell = shell-utils.myShell.${system};
          debPackages = [
            {
              package = "intel-basekit-2023.2.0-49384_amd64";
              hash = "sha256-ZlRDUwMN9Y7EKVbKzzWRNbGFHZrC/lps34pX/Ylqsrw=";
            }
            {
              package = "intel-hpckit-getting-started-2023.2.0-49438_all";
              hash = "sha256-yZPGFSa/+ki1cHGN2HHRWFoGz9rsFIC5rxFe1Hg9oQs=";
            }
            {
              package = "intel-oneapi-common-vars-2023.2.0-49462_all";
              hash = "sha256-52MaO9uaJTmuoSRf18Nlf/MdRxFVNL1rDofcYqlVOwU=";
            }
            {
              package = "intel-oneapi-common-licensing-2023.2.0-49462_all";
              hash = "sha256-vXQlCuywY2Iu41FYnr3y71Y4Cc2nP5R7BFEbG8DxBI4=";
            }
            {
              package = "intel-oneapi-dev-utilities-2021.10.0-49423_amd64";
              hash = "sha256-G4qRURUy2+rJpURoIZZIQtvURiUQCvoRVBdxsbC/zFc=";
            }
            {
              package = "intel-oneapi-inspector-2023.2.0-49301_amd64";
              hash = "sha256-yBEsKouU0REI1Hj1jCRQMoBJOjU3okuM+wp554NIfsA=";
            }
            {
              package = "intel-oneapi-itac-2021.10.0-11_amd64";
              hash = "sha256-oV8QmFnuvRJra42Mjh8qlcDGu+aOnrYzsB8Rg2Nsmh4=";
            }
            {
              package = "intel-oneapi-diagnostics-utility-2022.4.0-49091_amd64";
              hash = "sha256-dCSzP3WikHdTO5qIUJxc63pK9E1dMdmpxB+UqmstKFM=";
            }
            {
              package = "intel-oneapi-mpi-2021.10.0-2021.10.0-49371_amd64";
              hash = "sha256-sFl6rV+2uK/G6SpX4y+gE8NGmvd2jel5YTmdQTz4FAU=";
            }
            {
              package = "intel-oneapi-mpi-devel-2021.10.0-2021.10.0-49371_amd64";
              hash = "sha256-mPjRQ+pHDCIRjWaDHNUjEcLFtMUsZwunC/dzNhx/BvE=";
            }
            {
              package = "intel-oneapi-compiler-dpcpp-cpp-and-cpp-classic-2023.2.1-16_amd64";
              hash = "sha256-f5sO/KTCQKCp0ML5CjxilGJ7cO+xTnu6ofvmpZuQUMc=";
            }
            {
              package = "intel-oneapi-compiler-fortran-2023.2.1-16_amd64";
              hash = "sha256-LGY5eTVvblzzc4eF/fwsHYbJXUyUO3aaBh6wscrGTh8=";
            }
            {
              package = "intel-oneapi-compiler-shared-runtime-2023.2.1-2023.2.1-16_amd64";
              hash = "sha256-8WgKCM6FKNVBNDLYpucmYeFOjLHbR42Pie83g3FOCV0=";
            }
            {
              package = "intel-oneapi-compiler-dpcpp-cpp-runtime-2023.2.0-2023.2.0-49495_amd64";
              hash = "sha256-9j1HQA+F/rbB+wat4DkLriSBow3BDo4LRF0Y2nzs/PA=";
            }
          ];
          hpcKitDebs = map
            ({ package, hash }: pkgs.fetchurl {
              url = "https://apt.repos.intel.com/oneapi/pool/main/${package}.deb";
              inherit hash;
            })
            debPackages;
          hpcKit = pkgs.stdenv.mkDerivation {
            name = "hpcKit";
            source = self;
            dontUnpack = true;
            dontBuild = true;
            nativeBuildInputs = with pkgs; [
              autoPatchelfHook
            ];
            buildInputs = with pkgs; [
              zlib
              pango
              cairo
              fontconfig
              freetype
              gtk2
              sqlite
              xorg.libXxf86vm
              level-zero
              rdma-core
              numactl
              ucx
              libpsm2
              libffi_3_3
              tbb_2021_8
            ];
            installPhase = with pkgs; ''
              mkdir -p $out
              for deb in ${builtins.toString hpcKitDebs}; do
                echo "Extracting: $deb"
                # mkdir -p $out/$deb
                ${dpkg}/bin/dpkg-deb -x $deb $out
              done
            '';
          };
          # hpcKitBundle = pkgs.fetchurl {
          #   url = "https://registrationcenter-download.intel.com/akdlm/IRC_NAS/0722521a-34b5-4c41-af3f-d5d14e88248d/l_HPCKit_p_2023.2.0.49440_offline.sh";
          #   hash = "sha256-aIDny4lORvyzynQbqTokb2EPfCrCX07AOSocJD3rpKo=";
          #   executable = true;
          # };
          # hpcKitInstaller = pkgs.fetchurl {
          #   url = "https://installer.repos.intel.com/managed/installer/intel.installer.oneapi.linux.installer,v=4.3.2.892/installer.zip";
          #   hash = "sha256-wc/C1tRRB0kBN6s/M7dvMyxAZanEBnW0kuygx6NFhq8=";
          # };
          # hpcKitPackageManager = pkgs.fetchurl {
          #   url = "https://installer.repos.intel.com/managed/installer/intel.installer.packagemanager.linux,v=4.3.2-892/packagemanager.zip";
          #   hash = "sha256-DKlc3WXjisuy0s+3d14tLQiDHpNqa1k0ODdHyGxAbAE=";
          # };
          # hpcKit = pkgs.stdenv.mkDerivation {
          #   name = "hpcKit";
          #   src = self;
          #   nativeBuildInputs = [ pkgs.breakpointHook ];
          #   buildInputs = with pkgs; [
          #     ncurses
          #     strace
          #     pkg-config
          #     cmake
          #     git
          #     gnupg
          #     p7zip
          #     gnused
          #   ];
          #   dontConfigure = true;
          #   dontBuild = true;
          #   installPhase = with pkgs; ''
          #     HOME=$TMP
          #     USER=nix
          #     mkdir -p $TMP/intel/packagemanager/1.0
          #     mkdir -p $TMP/intel/oneapi/installer
          #     mkdir -p $TMP/intel/installercache
          #     mkdir -p $TMP/bundle
          #     ${hpcKitBundle} -f $TMP/bundle -x
          #     # ${p7zip}/bin/7z x -o$TMP/intel/oneapi/installer ${hpcKitInstaller}
          #     # ${p7zip}/bin/7z x -o$TMP/intel/packagemanager/1.0 ${hpcKitPackageManager}
          #     # patchelf --add-rpath "${stdenv.cc.cc.lib}/lib:${glibc}/lib" \
          #     #   $TMP/intel/oneapi/installer/installer
          #     # patchelf --set-interpreter "${stdenv.cc.libc}/lib/ld-linux-x86-64.so.2" \
          #     #   $TMP/intel/oneapi/installer/installer
          #     # patchelf --add-rpath "${stdenv.cc.cc.lib}/lib:${glibc}/lib" \
          #     #   $TMP/intel/packagemanager/1.0/packagemanager
          #     # patchelf --set-interpreter "${stdenv.cc.libc}/lib/ld-linux-x86-64.so.2" \
          #     #   $TMP/intel/packagemanager/1.0/packagemanager
          #     # HASH=$(sha384sum $TMP/intel/packagemanager/1.0/packagemanager | cut -d' ' -f1)
          #     # SIZE=$(stat -c "%s" $TMP/intel/packagemanager/1.0/packagemanager)
          #     # ${gnused}/bin/sed -i 's/\(sha384": "\).*"/\1'$HASH'"/' \
          #     #   $TMP/intel/packagemanager/1.0/packagemanager.json
          #     # ${gnused}/bin/sed -i 's/\(size": \).*$/\1'$SIZE'"/' \
          #     #   $TMP/intel/packagemanager/1.0/packagemanager.json
          #     patchelf --add-rpath "${stdenv.cc.cc.lib}/lib:${glibc}/lib" \
          #       $TMP/bundle/l_HPCKit_p_2023.2.0.49440_offline/bootstrapper
          #     patchelf --set-interpreter "${stdenv.cc.libc}/lib/ld-linux-x86-64.so.2" \
          #       $TMP/bundle/l_HPCKit_p_2023.2.0.49440_offline/bootstrapper
          #     HOME=$TMP TMPDIR=$TMP $TMP/bundle/l_HPCKit_p_2023.2.0.49440_offline/bootstrapper \
          #       --cli --silent --eula=accept --install-dir=$out --log-dir=. || true
          #     ls -l $TMP/intel/oneapi/installer
          #     patchelf --add-rpath "${stdenv.cc.cc.lib}/lib:${glibc}/lib" \
          #       $TMP/intel/oneapi/installer/installer
          #     patchelf --set-interpreter "${stdenv.cc.libc}/lib/ld-linux-x86-64.so.2" \
          #       $TMP/intel/oneapi/installer/installer
          #     HOME=$TMP TMPDIR=$TMP strace $TMP/intel/oneapi/installer/installer \
          #       --cli --silent --eula=accept --install-dir=$out --log-dir=. \
          #       --product-id=intel.oneapi.lin.hpckit.product \
          #       --product-ver=2023.2.0-49438 \
          #       --package-path=$TMP/bundle/l_HPCKit_p_2023.2.0.49440_offline/packages
          #   '';
          #   # doDist = true;
          #   # distPhase = with pkgs; ''
          #   #   patchelf --add-rpath "${stdenv.cc.cc.lib}/lib:${glibc}/lib" \
          #   #     $mytemp/extract/$KIT_NAME/bootstrapper
          #   #   patchelf --set-interpreter "${stdenv.cc.libc}/lib/ld-linux-x86-64.so.2" \
          #   #     $mytemp/extract/$KIT_NAME/bootstrapper
          #   #   echo "Out is $out"
          #   #   export HOME=$(pwd)
          #   #   export TMPDIR=$(pwd)
          #   #   export USER=nix
          #   #   $mytemp/extract/$KIT_NAME/bootstrapper --cli --silent --eula=accept --install-dir=$out --log-dir=.
          #   # '';
          #   #   patchelf --add-rpath \
          #   #     '$ORIGIN/'":${stdenv.cc.cc.lib}/lib:${glibc}/lib:${xorg.libXau}/lib:${xorg.libXdmcp}/lib:${libbsd}/lib:${libmd}/lib:${libxkbcommon}/lib" \
          #   #     $mytemp/extract/$KIT_NAME/{lib/*,plugins/tls/libqopensslbackend.so,plugins/platforms/libqxcb.so,plugins/imageformats/libqgif.so,"packages/intel.oneapi.lin.oneapi-common.vars,v=2023.2.0-49462/lin/install-history"}
          #   #   $mytemp/extract/$KIT_NAME/bootstrapper --help
          #   #   #$mytemp/extract/$KIT_NAME/install.sh --cli -s --eula --install-dir $out
          #   # '';
          # };
        in
        {
          devShells.default = shell {
            name = "Intel HPC Kit";
          };
          packages.default = hpcKit;
          packages.foo = hpcKitDebs;
        });
}
