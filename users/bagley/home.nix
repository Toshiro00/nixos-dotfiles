{ pkgs, ... }:
{
  home.username = "bagley";
  home.homeDirectory = "/home/bagley";
  home.stateVersion = "25.11";

  home.packages = with pkgs; [
    git
    helix
    htop
    tmux
    wget
    curl
  ];

  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      set -g fish_greeting
      set -g __blume_color yellow

      if test "$BLUME_THEME_PALETTE" = "cyan-dark"
        set __blume_color cyan
      else if test "$BLUME_THEME_PALETTE" = "mono-accent"
        set __blume_color white
      end

      set -l __blume_valid black red green yellow blue magenta cyan white brblack brred brgreen bryellow brblue brmagenta brcyan brwhite normal
      if not contains -- "$__blume_color" $__blume_valid
        set -g __blume_color yellow
      end

      if not set -q __blume_session_init
        set -g __blume_session_init 1
        set_color $__blume_color
        echo "[ctOS] $BLUME_THEME_BRAND"
        set_color normal
        echo "host: "(hostname)" | kernel: "(uname -r)
        echo "uptime: "(uptime | string trim)
        set ip4 (command ip -4 -o addr show scope global 2>/dev/null | head -n1 | awk '{print $4}')
        if test -n "$ip4"
          echo "ip: $ip4"
        end
        if command -sq zpool
          set zstate (zpool list -H -o health 2>/dev/null | head -n1)
          if test -n "$zstate"
            echo "zfs: $zstate"
          end
        end
      end
    '';
    functions.fish_prompt = ''
      set_color $__blume_color 2>/dev/null; or set_color yellow
      printf '[ctOS] '
      set_color normal
      printf '%s@%s %s> ' "$USER" (prompt_hostname) (prompt_pwd)
    '';
  };
}
