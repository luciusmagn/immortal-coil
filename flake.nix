{
  description = "Immortal Coil release builds";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    claylib = {
      url = "github:defun-games/claylib/3eb86bc5f6b88570e053e0eefed66384d2c28365";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, claylib }:
    let
      systems = [
        "x86_64-linux"
      ];

      forAllSystems = function:
        nixpkgs.lib.genAttrs systems
          (system: function (import nixpkgs { inherit system; }));
    in
    {
      packages = forAllSystems (pkgs:
        let
          lispPackages = pkgs.sbclPackages;

          sbclWithPackages = pkgs.sbcl.withPackages (ps: [
            ps.alexandria
            ps.cffi
            ps.cl-ppcre
            ps.closer-mop
            ps.eager-future2
            ps.livesupport
            ps.serapeum
            ps.static-dispatch
            ps.trivia
            ps.trivial-extensible-sequences
            ps.trivial-features
            ps.trivial-garbage
          ]);

          claylibLibraries = [
            pkgs.glfw
            pkgs.libGLU
            pkgs.libglvnd
            pkgs.stdenv.cc.cc.lib
            pkgs.libx11
            pkgs.libxau
            pkgs.libxcb
            pkgs.libxcursor
            pkgs.libxdmcp
            pkgs.libxext
            pkgs.libxi
            pkgs.libxinerama
            pkgs.libxrandr
            pkgs.libxxf86vm
            pkgs.zlib
          ];

          claylibPatched = pkgs.stdenv.mkDerivation {
            pname = "claylib";
            version = "3eb86bc5";
            src = claylib;

            nativeBuildInputs = [
              pkgs.autoPatchelfHook
            ];

            buildInputs = claylibLibraries;

            dontConfigure = true;
            dontBuild = true;

            installPhase = ''
              runHook preInstall

              mkdir -p "$out"
              cp -R . "$out/"
              chmod -R u+w "$out"

              runHook postInstall
            '';
          };

          source = pkgs.lib.cleanSourceWith {
            src = ./.;
            filter = path: type:
              let
                root = toString ./.;
                relativePath = pkgs.lib.removePrefix "${root}/" (toString path);
                name = baseNameOf path;
              in
              !(name == ".git"
                || name == "result"
                || name == ".env"
                || relativePath == "save"
                || pkgs.lib.hasPrefix "save/" relativePath);
          };

          libraryPath = pkgs.lib.makeLibraryPath claylibLibraries;
        in
        rec {
          dialog-editor = pkgs.stdenv.mkDerivation {
            pname = "immortal-coil-editor";
            version = "0.1.0";
            src = source;

            nativeBuildInputs = [
              pkgs.makeWrapper
              pkgs.nim
              pkgs.nimble
            ];

            dontConfigure = true;

            buildPhase = ''
              runHook preBuild

              export HOME="$TMPDIR/home"
              export NIMBLE_DIR="$TMPDIR/nimble"
              mkdir -p "$HOME" "$NIMBLE_DIR"

              pushd tools/dialog-editor
              nimble --legacy --offline --nimbleDir:"$NIMBLE_DIR" build -y
              popd

              runHook postBuild
            '';

            installPhase = ''
              runHook preInstall

              mkdir -p "$out/bin" "$out/libexec/immortal-coil-editor" "$out/share/immortal-coil"

              cp tools/dialog-editor/immortal_coil_editor "$out/libexec/immortal-coil-editor/"
              cp -R assets game tools "$out/share/immortal-coil/"

              makeWrapper "$out/libexec/immortal-coil-editor/immortal_coil_editor" "$out/bin/immortal-coil-editor" \
                --run 'if [ -z "''${IMMORTAL_COIL_EDITOR_ROOT:-}" ] && [ ! -f "./tools/dialog-editor/index.html" ]; then export IMMORTAL_COIL_EDITOR_ROOT="'"$out"'/share/immortal-coil"; fi'

              runHook postInstall
            '';
          };

          immortal-coil = pkgs.stdenv.mkDerivation {
            pname = "immortal-coil";
            version = "0.1.0";
            src = source;

            nativeBuildInputs = [
              pkgs.makeWrapper
              sbclWithPackages
            ];

            dontConfigure = true;

            buildPhase = ''
              runHook preBuild

              export HOME="$TMPDIR/home"
              mkdir -p "$HOME"

              export ASDF_OUTPUT_TRANSLATIONS="$PWD:/tmp/immortal-coil-fasl/"
              export LD_LIBRARY_PATH="${claylibPatched}/wrap/lib:${libraryPath}:''${LD_LIBRARY_PATH:-}"

              sbcl --no-userinit --no-sysinit --non-interactive \
                --eval '(require :asdf)' \
                --eval "(push (uiop:ensure-directory-pathname \"$PWD\") asdf:*central-registry*)" \
                --eval '(push #p"${claylibPatched}/" asdf:*central-registry*)' \
                --load nix/build-binary.lisp

              runHook postBuild
            '';

            installPhase = ''
              runHook preInstall

              mkdir -p "$out/bin" "$out/libexec/immortal-coil" "$out/share/immortal-coil"

              cp immortal-coil "$out/libexec/immortal-coil/"
              cp immortal-coil.asd "$out/share/immortal-coil/"
              cp -R assets game source "$out/share/immortal-coil/"

              makeWrapper "$out/libexec/immortal-coil/immortal-coil" "$out/bin/immortal-coil" \
                --set IMMORTAL_COIL_ROOT "$out/share/immortal-coil" \
                --prefix LD_LIBRARY_PATH : "${claylibPatched}/wrap/lib:${libraryPath}" \
                --run 'if [ -z "''${IMMORTAL_COIL_SAVE_DIR:-}" ]; then export IMMORTAL_COIL_SAVE_DIR="''${XDG_DATA_HOME:-$HOME/.local/share}/immortal-coil"; fi'

              runHook postInstall
            '';
          };

          default = immortal-coil;
        });

      apps = forAllSystems (pkgs:
        let
          system = pkgs.stdenv.hostPlatform.system;
        in
        {
          default = {
            type = "app";
            program = "${self.packages.${system}.immortal-coil}/bin/immortal-coil";
          };

          editor = {
            type = "app";
            program = "${self.packages.${system}.dialog-editor}/bin/immortal-coil-editor";
          };
        });

      devShells = forAllSystems (pkgs: {
        default = pkgs.mkShell {
          packages = [
            (pkgs.sbcl.withPackages (ps: [
              ps.alexandria
              ps.cffi
              ps.cl-ppcre
              ps.closer-mop
              ps.eager-future2
              ps.livesupport
              ps.serapeum
              ps.static-dispatch
              ps.trivia
              ps.trivial-extensible-sequences
              ps.trivial-features
              ps.trivial-garbage
            ]))
            pkgs.nim
            pkgs.nimble
            pkgs.ripgrep
          ];
        };
      });
    };
}
