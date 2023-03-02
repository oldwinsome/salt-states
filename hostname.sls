# Setting the hostname via `network.system` doesn't seem to play well with systemd.
{% if salt['pkg.version']('systemd').split('.')[0] == '247' %}
{%   set verb = 'set-hostname' %}
{% else %}
{%   set verb = 'hostname' %}
{% endif %}
hostnamectl:
  cmd.run:
    - name: 'hostnamectl {{ verb }} --static {{ pillar['hostname'] }}'
    - unless: '[ $(hostname) = "{{ pillar['hostname'] }}" ]'

/etc/ssh/ssh_host_dsa_key.pub:
  file.replace:
    - pattern: '^(.* root@).*'
    - repl: '\1{{ pillar['hostname'] }}'
    - show_changes: True
    - require:
      - cmd: hostnamectl

/etc/ssh/ssh_host_ed25519_key.pub:
  file.replace:
    - pattern: '^(.* root@).*'
    - repl: '\1{{ pillar['hostname'] }}'
    - show_changes: True
    - require:
      - cmd: hostnamectl

/etc/ssh/ssh_host_rsa_key.pub:
  file.replace:
    - pattern: '^(.* root@).*'
    - repl: '\1{{ pillar['hostname'] }}'
    - show_changes: True
    - require:
      - cmd: hostnamectl

/etc/ssh/ssh_host_ecdsa_key.pub:
  file.replace:
    - pattern: '^(.* root@).*'
    - repl: '\1{{ pillar['hostname'] }}'
    - show_changes: True
    - require:
      - cmd: hostnamectl
