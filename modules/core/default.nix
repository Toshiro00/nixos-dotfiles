{ pkgs, ... }:
{
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  programs.fish.enable = true;
  services.openssh.enable = true;
  programs.nix-ld.enable = true;

  environment.systemPackages = with pkgs; [
    git
    helix
    htop
    tmux
    wget
    curl
    tree
    nil
    nixfmt-rfc-style
  ];
}
