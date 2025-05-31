# timelockd

A daemon to run [timelock](https://github.com/rayanamal/timelock).

## Why?

Most decryption processes take a long time. This is good, otherwise timelock would have no value! But there are several issues:
- You need to be careful to maintain the program running in the background. You shouldn't accidentally kill it.
- Your user account needs to be logged in for the duration of decryption, especially if you don't have root access.

This script addresses these concerns by creating a systemd-activated system daemon. 

## How?

When you drop a file with the `.timelock` extension into the specified folder, systemd detects this and starts `timelockd`. 

- Drop a `.timelock` file into the folder for the decryption process to begin.
- Delete a `.timelock` file from the folder to cancel its ongoing decryption.
- Encrypted files are deleted when their decryption is complete.
- The daemon scans the folder every 30 seconds, so there might be a little delay after you drop/delete files.
- Any other files in the folder are ignored.

## Installation (on NixOS)

Disclaimer: For any seasoned NixOS user, all parts of the following might look horribly primitive.

1. Determine where will the daemon scan directory and the script be.
2. Add the following to your `configuration.nix`, fixing the indicated parts:
```nix
  systemd.paths.timelockd = {
    wantedBy = [ "multi-user.target" ];
    # FIXME the path below.
    pathConfig.PathExistsGlob = "/home/username/timelock/*.timelock";
  };

  systemd.services.timelockd = {
    # FIXME the path below.
  	script = "/etc/nixos/assets/timelockd.nu";
  	path = [ pkgs.nushell ];
  };
```
3. Install timelock on your system. You should have at least the `dtlp` binary somewhere.
4. Download the script in this repo. Adjust the two paths in the start to their correct locations in your system.
5. nixos-rebuild.