/etc/hosts:
  file.replace:
    - pattern: '(?<=127\.0\.1\.1\s)(\s+)[\w-]+$'
    - repl: '\1{{ pillar['hostname'] }}'
    - show_changes: True

# Enable the Raspberry Pi 4 Case Fan.
/boot/config.txt:
  file.blockreplace:
    - marker_start: '#-- start Salt-managed block --'
    - marker_end: '#-- end Salt-managed block --'
    - content: |
        [all]
        dtoverlay=gpio-fan,gpiopin=14,temp=80000
    - append_if_not_found: true
    - backup: false

# Enable screen blanking.
/etc/X11/xorg.conf.d/10-blanking.conf:
  file.absent: []
/etc/issue:
  file.replace:
    - pattern: '\n\033.*$'
    - repl: ''

# Disable automatic user login.
/etc/lightdm/lightdm.conf:
  file.replace:
    - pattern: ^#*autologin-user=.*
    - repl: '#autologin-user='
    - show_changes: True
/etc/systemd/system/getty@tty1.service.d/autologin.conf:
  file.absent: []

# The version of usbmount available in Raspberry Pi OS Buster doesn't work
# correctly, so we install a newer fixed version straight from the source.
usbmount:
  pkg.installed:
    - sources:
        - usbmount: https://github.com/nicokaiser/usbmount/releases/download/0.0.24/usbmount_0.0.24_all.deb

/etc/usbmount/usbmount.conf:
  file.replace:
    - pattern: '^FILESYSTEMS="((?:(?!\bexfat\b).)*)"$'
    - repl: 'FILESYSTEMS="\1 exfat"'
    - show_changes: True
    - require:
        - pkg: usbmount
