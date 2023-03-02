# Ensure we get Netdata packages from the official repository rather than Ubuntu.
{% if grains['os'] == 'Ubuntu' %}
/etc/apt/preferences.d/netdata:
  file.managed:
    - contents: |
        Package: netdata netdata-*
        Pin: origin "repo.netdata.cloud"
        Pin-Priority: 1000
{% endif %}

{% if grains['os'] == 'Raspbian' %}
{%   set netdata_configuration_root = '/opt/netdata/etc/netdata' %}
{% else %}
{%   set netdata_configuration_root = '/etc/netdata' %}
{% endif %}

netdata:
  cmd.run:
    - name: &download 'curl -so /tmp/netdata-kickstart.sh https://my-netdata.io/kickstart.sh && sh /tmp/netdata-kickstart.sh --non-interactive --auto-update --stable-channel'
    - creates: /etc/systemd/system/multi-user.target.wants/netdata.service
  service.running:
    - enable: True
    - require:
        - cmd: *download

{{ netdata_configuration_root}}/netdata.conf:
  file.blockreplace:
    - marker_start: '#-- start Salt-managed block --'
    - marker_end: '#-- end Salt-managed block --'
    - content: |
        [web]
            bind to = localhost {{ grains['host'] }}.{{ grains['dns']['search']|select('match', '.*\.ts\.net')|first }}
    - append_if_not_found: true
    - backup: false
    - watch_in:
        - service: netdata

{{ netdata_configuration_root}}/health_alarm_notify.conf:
  file.managed:
    - source: salt://files/netdata/health_alarm_notify.conf
    - user: netdata
    - group: netdata
    - mode: 0644
    - template: jinja
    - show_changes: False
    - watch_in:
        - service: netdata

