# Blume Corporation NixOS Fleet

This repository uses a fleet-ready NixOS layout with strict naming and responsibility boundaries.

## Principles

- Single canonical name per concept.
- Full one-word directory names only.
- SRP first: one concern per file/module.
- DRY second: extract only shared logic.
- Host files stay thin; reusable logic lives in `modules` and `lib`.

## Canonical Structure

```text
/etc/nixos
├── flake.nix
├── flake.lock
├── PLAN.md
├── README.md
├── lib
│   └── mkhost.nix
├── hosts
│   ├── common
│   │   └── default.nix
│   └── blume
│       ├── default.nix
│       ├── access
│       │   ├── default.nix
│       │   └── network.nix
│       ├── service
│       │   ├── default.nix
│       │   ├── container.nix
│       │   ├── theme.nix
│       │   └── virtualization.nix
│       └── system
│           ├── default.nix
│           ├── boot.nix
│           ├── compute.nix
│           ├── disk.nix
│           └── hardware.nix
├── modules
│   ├── default.nix
│   ├── core/default.nix
│   ├── security/default.nix
│   ├── virtualization/default.nix
│   ├── container/default.nix
│   ├── theme/default.nix
│   └── zfs/default.nix
└── users
    ├── common/default.nix
    └── bagley
        ├── default.nix
        └── home.nix
```

## Contracts

- `flake.nix` builds hosts via `lib/mkhost.nix`.
- `hosts/blume/default.nix` is an import map plus host identity/state.
- `modules/theme/default.nix` owns `blume.theme.*` options.
- `users/bagley/default.nix` composes user-specific and common Home Manager modules.

## Documentation

- [Principles](docs/PRINCIPLES.md)
- [Troubleshooting](docs/TROUBLESHOOTING.md)

## Build

```bash
sudo nixos-rebuild build --flake .#blume
```
