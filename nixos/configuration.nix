{ config, pkgs, ... }:

{
  imports = [ ./hardware-configuration.nix ];

   hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
  };

 hardware.nvidia = {

    # Modesetting is needed for most Wayland compositors
    modesetting.enable = true;

    # Use the open source version of the kernel module
    # Only available on driver 515.43.04+
    open = false;

    # Enable the nvidia settings menu
    nvidiaSettings = true;

    # Optionally, you may need to select the appropriate driver version for your specific GPU.
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking = {
    hostName = "nixos";
    networkmanager.enable = true;
  };

  time.timeZone = "America/Mexico_City";
  i18n.defaultLocale = "en_US.UTF-8";

  # X11 and Desktop Environment.
  services.xserver = {
    enable = true;
    displayManager.lightdm.enable = true;
    desktopManager.cinnamon.enable = true;
    videoDrivers = [ "nvidia" ];
    layout = "us";
  };
xdg.portal.enable = true; # only needed if you are not doing Gnome
services.flatpak.enable = true;

  services.printing.enable = true;

  # Sound with pipewire.
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

 virtualisation.docker.enable = true;
  virtualisation.docker.storageDriver = "overlay2";


  services.postgresql = {
    enable = true;
    package = pkgs.postgresql_13;
    initialScript = pkgs.writeText "postgresql-init.sql" ''
      CREATE EXTENSION postgis;
    '';
  };

  users.users.david = {
    isNormalUser = true;
    description = "david";
    extraGroups = [ "networkmanager" "wheel" "docker"  ]; # Added docker group
    packages = with pkgs; [ brave firefox ];
  };
 

  services.xserver.displayManager.autoLogin = {
    enable = true;
    user = "david";
  };

  # System packages.
environment.systemPackages = with pkgs; [
    vscodium
    git 
    gnumake
    spotify
    python3 
    yarn
    tmux
    terminator
    nodejs
    brave
    openjdk11  # Replaced "java" with "openjdk11" to specify version
    rustc
    cargo
    (pkgs.writeShellScriptBin "code" ''
      flatpak run --filesystem=/etc/nixos com.visualstudio.code "$@"
    '')
  ];

  # System configuration.
  system.stateVersion = "23.05";

  nixpkgs.config.allowUnfree = true;
}

