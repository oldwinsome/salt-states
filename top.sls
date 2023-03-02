main:
  'hostname:*':
    - match: pillar
    - hostname
  '*':
    - base
    - tailscale
    - {{ grains['os'] | lower }}
    - netdata
  'flightradar24_sharing_key:*':
    - match: pillar
    - flightradar24
  'piaware_feeder_id:*':
    - match: pillar
    - piaware
  'matterbridge_discord_token:*':
    - match: pillar
    - matterbridge
