Got it. Here’s a **clean “Blume Corporation standard”** that scales from 1 host to many, keeps **shared vs host-unique** sharp, and gives you obvious places for **VMs (Windows/libvirt)** and **containers (nspawn/containers.*)** without turning `/etc/nixos` into spaghetti.

Below I’ll show:

1. A refactored tree (opinionated but practical)
2. The “rules” (what goes where)
3. Minimal example `flake.nix` + module layout
4. How to add: host-specific overrides, roles, per-host secrets, VM/container modules

---

## 1) Recommended tree

```text
/etc/nixos
├── flake.nix
├── flake.lock
├── lib
│   ├── mkHost.nix
│   └── mkUser.nix
├── hosts
│   ├── blume
│   │   ├── default.nix              # entrypoint for this host
│   │   ├── hardware.nix             # from hardware-configuration.nix (rename)
│   │   ├── disk.nix                 # zfs/disko or storage specifics (optional)
│   │   ├── network.nix              # bridge, vlan, firewall, hostnames
│   │   ├── virtualization.nix       # libvirt/vfio toggles for this host
│   │   ├── containers.nix           # containers for this host
│   │   └── secrets.nix              # sops/agenix wiring (optional)
│   └── _common
│       ├── default.nix              # common host settings (timezone, nix, etc.)
│       └── security.nix             # baseline hardening shared across hosts
├── modules
│   ├── core
│   │   ├── default.nix              # imports baseline modules
│   │   ├── nix.nix
│   │   ├── locale.nix
│   │   ├── ssh.nix
│   │   └── users.nix
│   ├── security
│   │   ├── default.nix
│   │   ├── kernel-hardening.nix
│   │   └── firewall.nix
│   ├── virtualization
│   │   ├── default.nix
│   │   ├── libvirt.nix              # KVM/libvirt defaults
│   │   ├── vfio.nix                 # IOMMU + vfio-pci wiring (host opts)
│   │   └── windows-vm.nix            # optional “opinionated” VM profile
│   ├── containers
│   │   ├── default.nix
│   │   ├── nspawn.nix               # containers.* defaults + NAT/bridge helpers
│   │   └── profiles
│   │       ├── web.nix
│   │       ├── monitoring.nix
│   │       └── buildbox.nix
│   └── zfs
│       ├── default.nix
│       └── scrub.nix
└── users
    ├── bagley
    │   ├── default.nix              # HM module entry
    │   └── home.nix                 # your current content (keep)
    └── _common
        └── default.nix              # shared HM defaults
```

### Why this works

* `hosts/<name>/` is the **only** place you keep machine-specific stuff.
* `modules/` is **only reusable** building blocks.
* `hosts/_common` gives you “corp baseline” for hosts.
* `users/_common` gives you baseline for home-manager users.

---

## 2) “Blume standard” rules

**Rule A — no host logic in shared modules**
`modules/**` must be reusable across any host. If you need a hostname or NIC name, pass it via options or set it in `hosts/<name>/network.nix`.

**Rule B — hosts are thin**
`hosts/<name>/default.nix` should mostly be *imports* + 10–30 lines of real settings.

**Rule C — roles/profiles are modules**
“this host is a hypervisor” is a module (`modules/virtualization/*`).
“this container is a web service” is a container profile module (`modules/containers/profiles/web.nix`).

**Rule D — keep hardware separate**
Rename `hardware-configuration.nix` to `hardware.nix` and don’t edit it much.

---

## 3) Minimal implementation

### `lib/mkHost.nix`

A helper that reduces flake boilerplate:

```nix
{ nixpkgs, home-manager }:
{ system, hostName, userName ? null, extraModules ? [ ] }:

nixpkgs.lib.nixosSystem {
  inherit system;
  specialArgs = { inherit hostName userName; };
  modules =
    [
      ../hosts/_common
      ../hosts/${hostName}
      ../modules
      ( { networking.hostName = hostName; } )
    ]
    ++ nixpkgs.lib.optionals (userName != null) [
      home-manager.nixosModules.home-manager
      {
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.users.${userName} = import ../users/${userName};
      }
    ]
    ++ extraModules;
}
```

### `hosts/blume/default.nix`

```nix
{ ... }:
{
  imports = [
    ./hardware.nix
    ./network.nix
    ./virtualization.nix
    ./containers.nix
    # ./secrets.nix
    # ./disk.nix
  ];

  system.stateVersion = "24.11";
}
```

### `hosts/_common/default.nix`

```nix
{ ... }:
{
  imports = [
    ./security.nix
    ../_common/security.nix
    ../../modules/core
    ../../modules/security
  ];

  time.timeZone = "Europe/Istanbul";
}
```

### `modules/default.nix`

```nix
{ ... }:
{
  imports = [
    ./core
    ./security
    ./zfs
    ./virtualization
    ./containers
  ];
}
```

### `flake.nix`

```nix
{
  description = "Blume Corporation NixOS Fleet";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    home-manager.url = "github:nix-community/home-manager/release-24.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, home-manager, ... }:
  let
    mkHost = import ./lib/mkHost.nix { inherit nixpkgs home-manager; };
  in
  {
    nixosConfigurations = {
      blume = mkHost {
        system = "x86_64-linux";
        hostName = "blume";
        userName = "bagley";
      };
    };
  };
}
```

---

## 4) Where your VM + containers live

### Host toggles: `hosts/blume/virtualization.nix`

Keep *this host’s* IOMMU params, vfio IDs, etc. here:

```nix
{ ... }:
{
  # enable shared libvirt defaults from modules/virtualization/libvirt.nix
  blume.virtualization.libvirt.enable = true;

  # host-specific passthrough settings (GPU IDs, kernel params, etc.)
  blume.virtualization.vfio = {
    enable = true;
    # gpuPciIds = [ "10de:1b80" "10de:10f0" ]; # example
  };
}
```

Then implement those options in `modules/virtualization/vfio.nix` (reusable), not in the host.

### Host container definitions: `hosts/blume/containers.nix`

This file should be *definitions of instances* (like Proxmox CT list). Profiles in modules.

```nix
{ ... }:
{
  blume.containers.enable = true;

  containers.web = {
    autoStart = true;
    privateNetwork = true;
    hostAddress = "10.200.0.1";
    localAddress = "10.200.0.2";
    config = import ../../modules/containers/profiles/web.nix;
  };
}
```

---

## 5) Your current tree → migration steps (safe + clean)

1. Move `hosts/blume/configuration.nix` → `hosts/blume/default.nix`
2. Move `hosts/blume/hardware-configuration.nix` → `hosts/blume/hardware.nix`
3. Create `hosts/blume/network.nix`, `virtualization.nix`, `containers.nix` and *cut/paste* relevant chunks
4. Turn your existing `modules/core/default.nix` into the main baseline import (or adopt the structure above)
5. Keep `users/bagley/home.nix`, add `users/bagley/default.nix` that just imports it.

Example `users/bagley/default.nix`:

```nix
{ ... }:
{
  imports = [
    ./home.nix
    ../_common/default.nix
  ];
}
```

---

## If you want the “corp vibe” naming convention

* Prefix reusable options with a namespace like `blume.*`:

  * `blume.virtualization.vfio.enable`
  * `blume.containers.enable`
  * `blume.security.baseline.enable`

That prevents option collisions and feels like an internal platform.

---

If you paste your current `hosts/blume/configuration.nix` (and any VFIO/container bits you already have), I’ll rewrite them into this structure *exactly*, including:

* where each chunk should live
* what becomes a reusable module vs host-only
* a sane default for “secure + performance” (libvirt hardening + container limits)
