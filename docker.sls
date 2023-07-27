docker:
  pkgrepo.managed:
    - name: deb [signed-by=/etc/apt/keyrings/docker-archive-keyring.gpg arch=amd64] https://download.docker.com/linux/ubuntu {{ grains['lsb_distrib_codename'] }} stable
    - file: /etc/apt/sources.list.d/docker.list
    - key_url: https://download.docker.com/linux/ubuntu/gpg
    - aptkey: False
  pkg.latest:
    - pkgs:
        - containerd.io
        - docker-ce
        - docker-ce-cli
    - install_recommends: False

  # service.running:
  # - enable: True
