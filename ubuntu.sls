/etc/update-manager/release-upgrades:
  file.replace:
    - pattern: '^Prompt=.*'
    - repl: 'Prompt=normal'
    - show_changes: True

salt:
  pkgrepo.managed:
    - name: deb [signed-by=/etc/apt/keyrings/salt-archive-keyring.gpg arch=amd64] https://repo.saltproject.io/salt/py3/ubuntu/22.04/amd64/latest jammy main
    - file: /etc/apt/sources.list.d/salt.list
    - key_url: https://repo.saltproject.io/salt/py3/ubuntu/22.04/amd64/SALT-PROJECT-GPG-PUBKEY-2023.gpg
    - aptkey: False

# Are we in OVH?
{% if salt.network.calc_net(grains['ip4_gw'], 22) == '54.38.32.0/22' %}
/etc/cloud/cloud.cfg:
  file.replace:
    - name: /etc/cloud/cloud.cfg
    - pattern: '^fqdn:.*'
    - repl: 'fqdn: {{ pillar['hostname'] }}.{{ pillar['dns_domain'] }}'
    - append_if_not_found: True
    - show_changes: True
    - require:
      - cmd: hostnamectl

{%   if pillar['ipv6_address'] %}
/etc/hosts:
  file.replace:
    - pattern: '(?<=127\.0\.1\.1\s)(\s+)[\w-]+\.[\w.-]+(\s+)[\w-]+$'
    - repl: '\1{{ pillar['hostname'] }}\2{{ pillar['dns_domain'] }}'
    - show_changes: True

/etc/netplan/51-ipv6.yaml:
  file.managed:
    - contents: |
        network:
          version: 2
          ethernets:
            {{ salt['network.default_route']('inet')[0]['interface'] }}:
                dhcp6: False
                match:
                  macaddress: {{ grains['hwaddr_interfaces'][salt['network.default_route']('inet')[0]['interface']] }}
                addresses:
                  - {{ pillar['ipv6_address'] }}/128
                routes:
                  - to: {{ pillar['ipv6_gateway'] }}
                    scope: link
                  - to: ::/0
                    via: {{ pillar['ipv6_gateway'] }}
                    on-link: True
  cmd.run:
    - name: netplan apply
    - onchanges:
      - file: /etc/netplan/51-ipv6.yaml

# We normally want to block incoming SSH connections from the internet, as Tailscale provides
# a more secure route in to the server. By blocking the SSH in the OVH firewall, rather than
# the host-level software firewall, we leave a 'break-glass' way to get in to the server (by
# disabling that OVH firewall rule) if Tailscale fails. Unfortunately the OVH firewall covers
# only IPv4, not IPv6. Here we configure the software firewall to allow incoming SSH connections
# only via IPv4, leaving IPv6 covered by the default deny rule.
'ufw allow proto tcp to 0.0.0.0/0 port 22':
  cmd.run:
    - unless: ufw show added | grep '^ufw allow 22/tcp$'
    - require_in:
      - cmd: 'ufw enable'

'ufw allow in on tailscale0':
  cmd.run:
    - unless: ufw show added | grep '^ufw allow in on tailscale0$'
    - require_in:
      - cmd: 'ufw enable'
{%   endif %}
{% endif %}

'ufw enable':
  cmd.run:
    - unless: "ufw status | grep '^Status: active$'"
