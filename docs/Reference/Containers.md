---
title: Quick Tips for Container Engines
---

```
# Get a container's local IP address
podman inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' container
```
