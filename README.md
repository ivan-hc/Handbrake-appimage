This repository creates and distributes the unofficial Appimage of Handbrake.

From here you can download the scripts to build from Debian and on top of [JuNest](https://github.com/fsquillace/junest), the lightweight Arch Linux based distro that runs, without root privileges, on top of any other Linux distro.

# How to integrate Handbrake AppImage into the system
The easier way is to install "AM" on your PC, see [ivan-hc/AM-application-manager](https://github.com/ivan-hc/AM-application-manager) for more.

Alternatively, you can install it this way:

    wget https://raw.githubusercontent.com/ivan-hc/AM-Application-Manager/main/programs/x86_64/handbrake
    chmod a+x ./handbrake
    sudo ./handbrake
The AppImage will be installed in /opt/handbrake as `handbrake`, near other files.
### Update

    /opt/handbrake/AM-updater
### Uninstall

    sudo /opt/handbrake/remove
