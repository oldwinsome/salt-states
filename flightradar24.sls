flightradar24_prerequisites:
  pkg.latest:
    - install_recommends: False
    - pkgs:
        - dirmngr

fr24feed:
  pkgrepo.managed:
    - name: deb http://repo.feed.flightradar24.com flightradar24 raspberrypi-stable
    - file: /etc/apt/sources.list.d/flightradar24.list
    - keyid: C969F07840C430F5
    - keyserver: keyserver.ubuntu.com
    - clean_file: True
  pkg.latest:
    - install_recommends: False
    - require:
        - pkg: flightradar24_prerequisites
        - pkgrepo: fr24feed
  service.running:
    - enable: True
  # Remove user from lightdm login window.
  user.present:
    - name: fr24
    - shell: /usr/sbin/nologin

/etc/fr24feed.ini:
  file.managed:
    - contents: |
        receiver="avr-tcp"
        fr24key="{{ pillar['flightradar24_sharing_key'] }}"
        host="127.0.0.1:30002"
        bs="no"
        raw="no"
        logmode="2"
        logpath="/var/log/fr24feed"
        mlat="no"
        mlat-without-gps="no"
    - watch_in:
        - service: fr24feed
