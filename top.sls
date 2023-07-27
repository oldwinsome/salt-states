main:
  'hostname:*':
    - match: pillar
    - hostname
  '*':
    - {{ grains['os'] | lower }}
    - base
    - tailscale
    - netdata
  'gotosocial_version:*':
    - match: pillar
    - gotosocial
  'flightradar24_sharing_key:*':
    - match: pillar
    - flightradar24
  'matterbridge_discord_token:*':
    - match: pillar
    - matterbridge
  'piaware_feeder_id:*':
    - match: pillar
    - piaware
