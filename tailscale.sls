gnupg:
  pkg.latest:
    - install_recommends: False

# Remove after apt 2.4.
/etc/apt/keyrings:
  file.directory

tailscale:
  # Move this into `pkgrepo.managed` from Salt 3005.
  file.managed:
    - name: /etc/apt/keyrings/tailscale-archive-keyring.gpg
    - source: https://pkgs.tailscale.com/stable/{{ grains['os']|lower }}/{{ grains['oscodename'] }}.noarmor.gpg
    - skip_verify: True
  pkgrepo.managed:
    - name: 'deb [signed-by=/etc/apt/keyrings/tailscale-archive-keyring.gpg] https://pkgs.tailscale.com/stable/{{ grains['os']|lower }} {{ grains['oscodename'] }} main'
    - file: /etc/apt/sources.list.d/tailscale.list
    - clean_file: True
    - require:
      - file: tailscale
    - require_in:
      - pkg: tailscale
  pkg.latest:
    - install_recommends: False
    - pkgs:
      - tailscale

tailscaled:
  service.running:
    - enable: True
    - require:
        - pkg: tailscale
