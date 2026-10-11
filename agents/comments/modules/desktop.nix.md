# desktop.nix

## Thunderbolt devices

Thunderbolt security is `user`: a device connected after boot gets no display,
USB or PCIe until it is authorised. An unauthorised Thunderbolt monitor shows as
every NVIDIA connector `disconnected`.

`bolt` authorises enrolled devices. To enrol a new one, find its UUID and enrol
it with the `auto` policy:

```
boltctl list
boltctl enroll --policy auto <uuid>
```

`boltctl` takes the UUID, not the sysfs name (`0-3`). KDE's Thunderbolt settings
page does the same through `bolt`.

Enrolled: BenQ PD3220U (`006ae1a8-33eb-c401-ffff-ffffffffffff`).

## NVIDIA power management

`powerManagement.enable` sets `NVreg_PreserveVideoMemoryAllocations=1` and adds
`nvidia-suspend`/`nvidia-resume`, which save video memory to `/tmp` across
suspend. `finegrained` (RTD3) stays off: it needs Turing or newer (the P2000 is
Pascal) and PRIME offload.
