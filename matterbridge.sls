/usr/local/bin/matterbridge:
  # The Salt Stack HTTP client, unhelpfully, doesn't follow HTTP redirects, so I can't download directly from file.managed.
  cmd.run:
    - name: &download 'curl -LsSo /usr/local/bin/matterbridge https://github.com/42wim/matterbridge/releases/download/v1.25.2/matterbridge-1.25.2-linux-64bit'
    - unless: '[ "$(matterbridge --version 2>/dev/null | cut -d" " -f2)" = 1.25.2 ]'
  file.managed:
    - user: matterbridge
    - group: matterbridge
    - mode: 0755
    - create: False
    - replace: False
    - onchanges:
      - cmd: *download
    - require:
      - user: matterbridge

/usr/local/etc/matterbridge.toml:
  file.managed:
    - source: salt://files/matterbridge.toml
    - user: matterbridge
    - group: matterbridge
    - mode: 0400
    - template: jinja

/etc/systemd/system/matterbridge.service:
  file.managed:
    - contents: |
        [Unit]
        Description=Matterbridge
        After=network.target

        [Service]
        Type=exec
        ExecStart=/usr/local/bin/matterbridge -conf /usr/local/etc/matterbridge.toml
        RestartSec=5
        Restart=always
        User=matterbridge
        Group=matterbridge
        ProtectProc=noaccess
        ProtectSystem=strict
        ProtectHome=yes

        [Install]
        WantedBy=multi-user.target
    - require:
      - file: /usr/local/bin/matterbridge
      - file: /usr/local/etc/matterbridge.toml
  module.run:
    - name: service.systemctl_reload
    - onchanges:
      - file: /etc/systemd/system/matterbridge.service

matterbridge:
  user.present:
    - system: True
  service.running:
    - enable: True
    - onchanges:
      - module: /etc/systemd/system/matterbridge.service
