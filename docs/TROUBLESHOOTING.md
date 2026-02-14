# Troubleshooting Guide

This document captures common issues, errors, and their solutions encountered during the management of the ctOS NixOS configuration.

## Containers

### Issue: `container@name.service` fails with `Error: code: 17 (File exists)`

**Symptoms:**
- `nixos-rebuild switch` fails.
- `systemctl status container@name.service` shows `(code=exited, status=1/FAILURE)` with `Error: code: 17 (File exists)`.
- `journalctl` logs show `Machine 'name' already exists`.

**Cause:**
This usually occurs when a previous instance of the container didn't shut down cleanly, or a `nixos-container run` session is still active/hung, keeping the machine name registered in `systemd-machined`.

**Solution:**
1. Check for registered machines:
   ```bash
   machinectl list
   ```
2. If the machine is listed but the service is down, try terminating it:
   ```bash
   sudo machinectl terminate <name>
   ```
3. If it persists, look for hung processes related to the container:
   ```bash
   ps aux | grep <name>
   ```
   Look for `nixos-container run` or `nsenter` processes and kill them:
   ```bash
   sudo kill -9 <PIDs>
   ```
4. Reset the failed service state and start again:
   ```bash
   sudo systemctl reset-failed container@<name>.service
   sudo systemctl start container@<name>.service
   ```

---

## Services

### Issue: Homepage Dashboard `400 Bad Request` (Host Validation Failed)

**Symptoms:**
- The Homepage UI loads but shows "Host validation failed" or errors in the browser console.
- Container logs (`journalctl -u homepage-dashboard`) show: `error: Host validation failed for: <hostname>:<port>. Hint: Set the HOMEPAGE_ALLOWED_HOSTS environment variable`.

**Cause:**
Homepage implements a security check to prevent DNS rebinding attacks by validating the `Host` header against an allowed list. By default, it may only allow `localhost`.

**Solution:**
Explicitly set the `HOMEPAGE_ALLOWED_HOSTS` environment variable in the container configuration. Since the NixOS module might provide a default, use `lib.mkForce`.

```nix
config = { pkgs, lib, ... }: {
  systemd.services.homepage-dashboard.environment = {
    HOMEPAGE_ALLOWED_HOSTS = lib.mkForce "blume,10.0.0.241,localhost,127.0.0.1,blume:8081";
  };
}
```
