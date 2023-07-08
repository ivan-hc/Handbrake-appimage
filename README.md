This repository provides the script to create and install Handbrake built from from Debian Stable.

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
