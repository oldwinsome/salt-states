Salt states for managing my servers.

# Bootstrapping

* Bootstrap SaltStack.

```shell
# apt --no-install-recommends install python3-pygit2 salt-minion
[copy keys to /etc/salt/gpgkeys]
# curl -o /etc/salt/minion.d/minion.conf https://raw.githubusercontent.com/wmoldwin/salt-states/main/files/minion.conf
# salt-call --local state.apply
```

* Generate Tailscale auth key with `server` tag.

```shell
# tailscale up --auth-key [$authkey] --ssh
```

* Claim node in Netdata.

* Reboot.

# Applying/Updating

```shell
# salt-call --local state.apply
```
