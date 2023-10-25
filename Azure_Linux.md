# ECX on Azure Linux

ECX is confirmed to run on Azure Linux (CBL Mariner) with some caveats.

----

## Versions in the validation

- EXPRESSCLUSTER X 5.1 for Linux (5.1.1-1)
- CBL-Mariner 2.0 (2.0.20231004)

## Notes

- `Mirror Disk` resource cannot be used.
- Use `User Mode` heartbeat instead of `Kernel Mode` heartbeat.
- Use `softdog` instead of `keepalive` for `userw` monitor resource.
- `clpfwctrl.sh` could not be used. Custom settings of firewall (`iptables`) are required for heartbeat and other communications.
  - `systemctl disable iptables` was used on the validation.

## TBD

- Check if DRBD is usable for disk replication.
