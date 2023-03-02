nano:
  pkg.purged

updates:
  pkg.uptodate:
  - refresh: True

salt-minion:
  pkg.latest:
  - install_recommends: False
  service.dead:
  - enable: False
  - require:
    - pkg: salt-minion

/etc/salt/minion.d/minion.conf:
  file.managed:
  - source: salt://files/minion.conf
  - require:
    - pkg: salt-minion

/etc/sudoers.d/sudoers:
  file.managed:
  - source: salt://files/sudoers
  - mode: 440

ssh:
  service.running:
  - enable: True

/etc/timezone:
  file.managed:
    - contents: Etc/UTC

william:
  user.present:
    - groups:
      - sudo
      - users
      {% if grains['os'] == 'Raspbian' %}
      - adm
      - dialout
      - cdrom
      - audio
      - video
      - plugdev
      - games
      - input
      - netdev
      - lpadmin
      - spi
      - i2c
      - gpio
      {% endif %}
    - createhome: True
    - shell: /bin/bash
    - fullname: William Oldwin
  ssh_auth.present:
    - name: AAAAC3NzaC1lZDI1NTE5AAAAIPKOgbEQCKZtXBp+8wXIHzvkn5uG8utkwFwmbGp65yBb
    - user: william
    - enc: ed25519
    - comment: Brimborion
    - require:
      - user: william

# only needed for Scaleway
root:
  user.present:
    - password: '*'
