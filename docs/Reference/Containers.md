---
title: Quick Tips for Container Engines
---

```
# Get a container's local IP address
podman inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' container

# Get a list of a container's mounts
podman inspect -f '{{range.Mounts}}{{.Source}} {{.Destination}}\n{{end}}' container

# Save a network configuration to a file. This uses the network configuration that's
# stored at /etc/cni/net.d/network_name.conflist.
podman network inspect network_name | jq .[] > ~/network-file.json
```
