# FAF on Linux

A set of scripts to automatically set up Supreme Commander: Forged Alliance with [Forged Alliance Forever](https://faforever.com/) on Linux. Tested on Ubuntu, should work on other distributions as well.

## How to setup

1. Clone this repository (`git clone https://github.com/iczero/faf-linux`) and install the prerequisites `git wget jq cabextract` from your distribution's package manager.
1. Run Forged Alliance from Steam with Proton Experimental at least once (this is necessary to set up proton)
1. Run `./setup.sh` to set up the local wine prefix, the FAF client, java, and others
1. Start the FAF client with `./run` and log in
1. After logging in, close the FAF client and run `./set-client-paths.sh`

## Updating components

The script `./update-component.sh` is provided for convenient updating of certain parts.

- To update dxvk, run `./update-component.sh dxvk <new version>`. Versions look like "1.9.3".
- To update the FAF client, run `./update-component.sh faf-client <new version>`. Versions look like "2021.10.0".
- To update java, run `./update.component.sh "<java url>" "<javafx url>"`.
  - The FAF client (at time of writing) wants Java 15.
  - Java URL is currently <https://github.com/AdoptOpenJDK/openjdk15-binaries/releases/download/jdk-15.0.2%2B7/OpenJDK15U-jdk_x64_linux_hotspot_15.0.2_7.tar.gz>
  - JavaFX URL is currently <https://gluonhq.com/download/javafx-15-0-1-jmods-linux/>
  - These may change in the future. `setup.sh` will hopefully be updated with working URLs.
