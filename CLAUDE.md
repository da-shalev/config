# Monorepo

- NixOS config lives in `nix/` - hosts, modules, packages (nix overlays), npins
- TS/JS projects live in `packages/` (bun workspaces)
- Rust projects live in `crates/` (cargo workspace)

# Nix

- ALWAYS use `lib.getExe` to get a package's main binary, or `lib.getExe' pkgs.<name> "<binary>"` for a specific binary - never hardcode `/bin/` paths
- To rebuild NixOS, run `upgrade`. To fetch latest sources, run `update`. To build for next boot, run `bootgrade`. Never use `sudo nixos-rebuild` directly.
- Combine related NixOS options into nested attrsets instead of repeating prefixes (e.g. `networking.nftables = { enable = true; tables = ...; };` not `networking.nftables.enable = true; networking.nftables.tables = ...;`)
- Run `treefmt` after editing nix or lua files to format them
- Use `config.rebuild.notify` for ntfy push notifications: `${lib.getExe config.rebuild.notify} <title> <tags> <priority> [message]`
- NEVER remove commented out code
- ALWAYS prefer `mv` over `cp` + `rm`
- ALWAYS use NixOS module options and declarative config - never imperative commands, manual file edits, or non-reproducible steps. Everything must be reproducible through Nix.
