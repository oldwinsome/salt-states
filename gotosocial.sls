gotosocial:
  user.present:
    - system: True
  service.running:
    - enable: True
    - watch:
      - file: /srv/gotosocial/config.yaml
      - module: /etc/systemd/system/matterbridge.service

/srv/gotosocial:
  file.directory:
    - user: gotosocial
    - group: gotosocial
    - mode: 0750

/srv/gotosocial/config.yaml:
  file.managed:
    - user: gotosocial
    - group: gotosocial
    - contents: |
        host: sparingly.social
        port: 443
        db-type: sqlite
        db-address: /srv/gotosocial/sqlite.db
        web-template-base-dir: /usr/local/lib/gotosocial/web/template
        web-asset-base-dir: /usr/local/lib/gotosocial/web/assets
        accounts-registration-open: false
        media-remote-cache-days: 0
        storage-local-base-path: /srv/gotosocial/storage
        letsencrypt-enabled: true
        letsencrypt-cert-dir: /srv/gotosocial/certs
        letsencrypt-email-address: goto@sparingly.social
        oidc-enabled: true
        oidc-idp-name: Entra ID
        oidc-issuer: https://sts.windows.net/2c3ae5d6-0484-48c5-a3d6-bdcff3c67b17/
        oidc-client-id: 97a2ec99-3131-4980-85a2-f58dea46fcb3
        oidc-client-secret: {{ pillar['gotosocial_oidc_client_secret'] }}
        smtp-host: smtp.tem.scw.cloud
        smtp-port: 587
        smtp-username: 0b92f3a8-e178-4c73-9999-fa50a95eb17f
        smtp-password: {{ pillar['gotosocial_smtp_password'] }}
        smtp-from: goto@sparingly.social
    - require:
        - file: /srv/gotosocial

/etc/systemd/system/gotosocial.service:
  file.managed:
    - contents: |
        [Unit]
        Description=GoToSocial
        After=network.target

        [Service]
        User=gotosocial
        Group=gotosocial

        Type=exec
        Restart=on-failure

        ExecStart=/usr/local/bin/gotosocial --config-path /srv/gotosocial/config.yaml server start
        WorkingDirectory=/srv/gotosocial

        # Paths
        ProtectProc=noaccess

        # Capabilities
        CapabilityBoundingSet=~CAP_RAWIO CAP_MKNOD
        CapabilityBoundingSet=~CAP_AUDIT_CONTROL CAP_AUDIT_READ CAP_AUDIT_WRITE
        CapabilityBoundingSet=~CAP_SYS_BOOT CAP_SYS_TIME CAP_SYS_MODULE CAP_SYS_PACCT
        CapabilityBoundingSet=~CAP_LEASE CAP_LINUX_IMMUTABLE CAP_IPC_LOCK
        CapabilityBoundingSet=~CAP_BLOCK_SUSPEND CAP_WAKE_ALARM
        CapabilityBoundingSet=~CAP_SYS_TTY_CONFIG
        CapabilityBoundingSet=~CAP_MAC_ADMIN CAP_MAC_OVERRIDE
        CapabilityBoundingSet=~CAP_NET_ADMIN CAP_NET_BROADCAST CAP_NET_RAW
        CapabilityBoundingSet=~CAP_SYS_ADMIN CAP_SYS_PTRACE CAP_SYSLOG
        AmbientCapabilities=CAP_NET_BIND_SERVICE

        # Security
        NoNewPrivileges=yes

        # Sandboxing
        ProtectSystem=strict
        ProtectHome=yes
        ReadWritePaths=/srv/gotosocial
        PrivateTmp=yes
        PrivateDevices=yes
        ProtectKernelTunables=yes
        ProtectKernelLogs=yes
        ProtectKernelModules=yes
        ProtectControlGroups=yes
        RestrictAddressFamilies=AF_UNIX AF_INET AF_INET6
        RestrictNamespaces=yes
        LockPersonality=yes
        RestrictRealtime=yes

        # System call filtering
        SystemCallFilter=~@clock @debug @module @mount @obsolete @reboot @setuid @swap

        # Device access
        DevicePolicy=closed

        [Install]
        WantedBy=default.target
    - require:
      # - file: /usr/local/bin/gotosocial
      - file: /srv/gotosocial/config.yaml
  module.run:
    - name: service.systemctl_reload
    - onchanges:
      - file: /etc/systemd/system/gotosocial.service

ufw allow in http:
  cmd.run:
    - unless: ufw show added | grep '^ufw allow 80/tcp$'
    - onchanges_in:
      - cmd: ufw reload

ufw allow in https:
  cmd.run:
    - unless: ufw show added | grep '^ufw allow 443$'
    - onchanges_in:
      - cmd: ufw reload

ufw reload:
  cmd.run

sqlite3 /srv/gotosocial/sqlite.db '.backup /srv/gotosocial/backup.db':
  cron.present:
    - user: gotosocial
    - special: '@daily'
