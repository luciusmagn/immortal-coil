# Nix Release Notes

## Linux

Build the current Linux package:

```bash
nix build .#immortal-coil
```

Run it:

```bash
./result/bin/immortal-coil
```

The wrapper sets `IMMORTAL_COIL_ROOT` to the installed asset directory and uses
`$IMMORTAL_COIL_SAVE_DIR` for saves. If that variable is absent, saves go under
`${XDG_DATA_HOME:-$HOME/.local/share}/immortal-coil`.

This is the first useful Nix target: it builds a native SBCL executable and
installs the game data beside it. Before this can be a Steam Linux depot, we
still need a portability pass so the artifact targets the Steam Linux Runtime
instead of depending on Nix store paths.

## Windows

Do not expect `pkgsCross.mingwW64` to produce a Windows build for this project.
SBCL dumps native images for the host it is running on; it does not behave like
a normal C compiler that can cross-link a Windows executable from Linux.

The viable routes are:

1. Build on a real Windows runner with Windows SBCL, Raylib/Claylib DLLs, and a
   script equivalent to `nix/build-binary.lisp`.
2. Experiment with a Wine-based Nix build that runs Windows SBCL inside Wine and
   dumps a Windows executable there.
3. Move the release build to a Common Lisp implementation with a better
   cross-compilation story, such as ECL, if Claylib/CFFI compatibility holds.

For now, the Linux Nix package is real. The Windows target is a release
engineering task, not a one-line Nix cross package.
