# Principles

These are the non-negotiable design principles for this NixOS fleet.

## Core Principles

1. Single canonical name per concept.
2. Full one-word directory names only.
3. SRP first: one concern per file/module.
4. DRY second: extract only shared logic.
5. Host files stay thin; reusable logic lives in `modules/` and `lib/`.

## Architectural Principles

1. `flake.nix` declares inputs and host outputs only.
2. `lib/mkhost.nix` is the host composition entry point.
3. `hosts/<name>/default.nix` is an import map plus host identity/state.
4. Reusable options and behavior belong in `modules/<domain>/default.nix`.
5. User-specific Home Manager logic belongs in `users/<name>/`.

## Configuration Principles

1. Prefer explicit options over implicit defaults.
2. Keep host/service modules readable and predictable.
3. Keep security-sensitive settings visible and intentional.
4. Pin and update dependencies through `flake.lock`.
