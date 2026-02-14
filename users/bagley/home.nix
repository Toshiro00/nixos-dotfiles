{ pkgs, ... }:

{
  home.username = "bagley";
  home.homeDirectory = "/home/bagley";
  home.stateVersion = "25.11";

  # Bagley's Isolated Toolkit
  home.packages = with pkgs; [
    git helix htop tmux wget curl
  ];

  programs.home-manager.enable = true;
}
