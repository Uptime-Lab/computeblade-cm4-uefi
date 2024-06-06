# ComputeBlade/CM4 optimized UEFI Firmware Images
> [!CAUTION]
> THE CONFIGURATION IS PROBABLY NOT SANE FOR ALL USERS.

This is a fork of the amazing [pftf/RPi4](https://github.com/pftf/RPi4) project, which brings a UEFI images for the RaspberryPi 4 Model B.

# Adaptations compared to the pftf/RPi4 proejct

## Adjustments
- server-workload oriented -> limit GPU mem to 64MB
- overclock ComputeModule 4 to 2.0GHz

## Ease of use improvements
- Allow easy local builds using `make dist`

## Firmware specific configuration
- Configure features for the [ComputeBlade](http://computeblade.com)
- **Disable SD Card** (avoids modifying the UEFI image from the operating system)
- Additional device-tree overlays


## EDK2/UEFI specific changes
- Remove the default 3GB memory limit (**WARNING: this reduces compatibility**)
- Use device tree as system table by default (Required for exposing the PCIe bus to Linux)
