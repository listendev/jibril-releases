# Jibril Kubernetes Deployment

This document describes how to deploy Jibril on Kubernetes clusters.

## setup-k8s.sh

The `setup-k8s.sh` script deploys Jibril as a DaemonSet on Kubernetes clusters. It creates the necessary ConfigMap, DaemonSet, and other resources required to run Jibril properly with eBPF capabilities.

### Prerequisites

- Kubernetes cluster with version 1.16+
- Linux nodes with kernel 5.15+ or 6.x
- `kubectl` configured to communicate with your cluster
- Nodes with support for eBPF

### Usage

```bash
./setup-k8s.sh [OPTIONS]
```

### Options

| Option | Description | Default |
|--------|-------------|---------|
| `--namespace=NAME` | Kubernetes namespace | `security` |
| `--image=IMAGE` | Jibril container image | `garnetlabs/jibril:v0.0` |
| `--log-level=LEVEL` | Log level (quiet, fatal, error, warn, info, debug) | `info` |
| `--config=FILE` | Path to custom Jibril config.yaml file | (built-in config) |
| `--memory-request=SIZE` | Memory request | `256Mi` |
| `--memory-limit=SIZE` | Memory limit | `512Mi` |
| `--cpu-request=AMOUNT` | CPU request | `100m` |
| `--cpu-limit=AMOUNT` | CPU limit | `500m` |
| `--node-selector=EXPR` | Node selector expression (e.g. 'role=security') | |
| `--toleration=KEY:VAL:EFFECT` | Add toleration (can be used multiple times) | |
| `--output=FILE` | Output YAML to file | `jibril-k8s.yaml` |
| `--dry-run` | Print configuration without applying | |
| `--cleanup` | Remove existing Jibril resources from the cluster | |
| `--help` | Show help | |

### Examples

1. **Basic deployment with defaults**
   ```bash
   ./setup-k8s.sh
   ```

2. **Deploy to a custom namespace**
   ```bash
   ./setup-k8s.sh --namespace=monitoring
   ```

3. **Add node toleration**
   ```bash
   ./setup-k8s.sh --toleration=security-agent:true:NoSchedule
   ```

4. **Set custom memory limits**
   ```bash
   ./setup-k8s.sh --memory-limit=1Gi --memory-request=512Mi
   ```

5. **Target specific nodes with a node selector**
   ```bash
   ./setup-k8s.sh --node-selector=role=security
   ```

6. **Deploy on GPU nodes with higher CPU limits**
   ```bash
   ./setup-k8s.sh --node-selector=gpu=true --cpu-limit=2 --cpu-request=500m
   ```

7. **Configure multiple tolerations**
   ```bash
   ./setup-k8s.sh --toleration=security:true:NoSchedule --toleration=critical:true:NoExecute
   ```

8. **Use a custom Jibril configuration file**
   ```bash
   ./setup-k8s.sh --config=/path/to/my-jibril-config.yaml
   ```

9. **Preview configuration without applying**
   ```bash
   ./setup-k8s.sh --dry-run
   ```

10. **Save configuration to a custom file**
    ```bash
    ./setup-k8s.sh --output=jibril-prod.yaml
    ```

11. **Clean up existing deployment**
    ```bash
    ./setup-k8s.sh --cleanup --namespace=security
    ```

12. **Complete production deployment example**
    ```bash
    ./setup-k8s.sh --namespace=security-prod \
      --image=garnetlabs/jibril:latest \
      --config=/etc/jibril/prod-config.yaml \
      --memory-limit=2Gi \
      --memory-request=1Gi \
      --cpu-limit=1 \
      --toleration=security-monitoring:true:NoSchedule \
      --node-selector=security-tier=high
    ```

### Notes

- Jibril requires privileged access to run eBPF programs
- The script mounts necessary paths from the host:
  - `/sys/fs/bpf`
  - `/sys/kernel/debug`
  - `/sys`
  - `/proc`
  - `/var/log/jibril`
- Log files are stored in `/var/log/jibril` on the host
- Configuration is supplied via a ConfigMap