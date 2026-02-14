
{ pkgs, ... }:

{
  # Every machine in the grid needs these
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  
  services.openssh.enable = true;

  users.users.bagley = {
    isNormalUser = true;
    extraGroups = [ "wheel" "incus-admin" "kvm" ];
  };

  programs.nix-ld.enable = true;

  environment.systemPackages = with pkgs; [
    git helix htop tmux wget curl tree
    nil
    nixfmt-rfc-style
  ];
}
