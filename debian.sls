{% if salt.pillar.get('hostname') %}
/etc/hosts:
  file.replace:
    - pattern: '(?<=127\.0\.1\.1\s)(\s+)[\w-]+\.[\w.-]+(\s+)[\w-]+$'
    - repl: '\1{{ pillar['hostname'] }}\2{{ pillar['dns_domain'] }}'
    - show_changes: True
{% endif %}
