#!/bin/bash

# k8s.sh - Deploy Jibril as a daemonset on kubernetes. This script creates a daemonset to
# run Jibril on kubernetes nodes. It allows customizing namespace, node selection,
# tolerations, and resource limits.

set -e

# For debugging
if [ "${DEBUG}" = "true" ]; then
  set -x
fi

# Cleanup function
cleanup() {
  rm -f /tmp/jibril-template.yaml
}

# Set trap to ensure cleanup on exit
trap cleanup EXIT

# Default values
NAMESPACE="security"
IMAGE="garnetlabs/jibril:v1.7"
# IMAGE="garnetlabs/jibril:v0.0" # daily builds
LOG_LEVEL="info"
MEMORY_REQUEST="512Mi"
MEMORY_LIMIT="1024Mi"
CPU_REQUEST="500m"
CPU_LIMIT="2000m"
NODE_SELECTOR=""
OUTPUT_FILE="jibril-k8s.yaml"
DRY_RUN=false
CONFIG_FILE=""
CLEANUP=false

# Help function
show_help() {
  echo "Usage: $0 [OPTIONS]"
  echo "Deploy Jibril as a Kubernetes DaemonSet"
  echo
  echo "Options:"
  echo "  --namespace=NAME        Set Kubernetes namespace (default: security)"
  echo "  --image=IMAGE           Set Jibril container image (default: garnetlabs/jibril:v0.0)"
  echo "  --log-level=LEVEL       Set log level: quiet, fatal, error, warn, info, debug (default: info)"
  echo "  --config=FILE           Path to custom Jibril config.yaml file"
  echo "  --memory-request=SIZE   Set memory request (default: 2Gi)"
  echo "  --memory-limit=SIZE     Set memory limit (default: 2Gi)"
  echo "  --cpu-request=AMOUNT    Set CPU request (default: 1000m)"
  echo "  --cpu-limit=AMOUNT      Set CPU limit (default: 2000m)"
  echo "  --node-selector=EXPR    Set node selector expression (e.g. 'role=security')"
  echo "  --toleration=KEY:VAL:EFFECT   Add toleration (can be used multiple times)"
  echo "                          Example: --toleration=security:true:NoSchedule"
  echo "  --output=FILE           Output YAML to file instead of applying (default: jibril-k8s.yaml)"
  echo "  --dry-run               Print generated YAML but don't apply to cluster"
  echo "  --cleanup               Remove existing Jibril resources from the cluster"
  echo "  --help                  Show this help"
  echo
  echo "Examples:"
  echo "  $0 --namespace=monitoring --toleration=security:true:NoSchedule"
  echo "  $0 --memory-limit=1Gi --cpu-limit=1 --node-selector=role=monitoring"
  echo "  $0 --config=/path/to/my-jibril-config.yaml"
  echo "  $0 --dry-run --output=my-jibril.yaml"
}

# Parse arguments
TOLERATION_ARRAY=()
while [[ $# -gt 0 ]]; do
  case $1 in
  --namespace=*)
    NAMESPACE="${1#*=}"
    shift
    ;;
  --image=*)
    IMAGE="${1#*=}"
    shift
    ;;
  --log-level=*)
    LOG_LEVEL="${1#*=}"
    shift
    ;;
  --config=*)
    CONFIG_FILE="${1#*=}"
    shift
    ;;
  --memory-request=*)
    MEMORY_REQUEST="${1#*=}"
    shift
    ;;
  --memory-limit=*)
    MEMORY_LIMIT="${1#*=}"
    shift
    ;;
  --cpu-request=*)
    CPU_REQUEST="${1#*=}"
    shift
    ;;
  --cpu-limit=*)
    CPU_LIMIT="${1#*=}"
    shift
    ;;
  --node-selector=*)
    NODE_SELECTOR="${1#*=}"
    shift
    ;;
  --toleration=*)
    TOLERATION_ARRAY+=("${1#*=}")
    shift
    ;;
  --output=*)
    OUTPUT_FILE="${1#*=}"
    shift
    ;;
  --dry-run)
    DRY_RUN=true
    shift
    ;;
  --cleanup)
    CLEANUP=true
    shift
    ;;
  --help)
    show_help
    exit 0
    ;;
  *)
    echo "Unknown option: $1"
    show_help
    exit 1
    ;;
  esac
done

# Check if cleanup was requested
if [ "$CLEANUP" = true ]; then
  if command -v kubectl >/dev/null 2>&1; then
    echo "Cleaning up Jibril resources in namespace: $NAMESPACE"

    # Check if namespace exists
    if kubectl get namespace "$NAMESPACE" >/dev/null 2>&1; then
      # Delete DaemonSet and ConfigMap
      echo "Deleting Jibril DaemonSet..."
      kubectl delete daemonset -n "$NAMESPACE" jibril 2>/dev/null || echo "No DaemonSet found"

      echo "Deleting Jibril ConfigMap..."
      kubectl delete configmap -n "$NAMESPACE" jibril-config 2>/dev/null || echo "No ConfigMap found"

      # Check if there are any pods still terminating
      if kubectl get pods -n "$NAMESPACE" -l app=jibril 2>/dev/null | grep -q "Terminating"; then
        echo "Waiting for pods to terminate..."
        kubectl wait --for=delete pods -n "$NAMESPACE" -l app=jibril --timeout=60s 2>/dev/null ||
          echo "Some pods are still terminating. You may need to force delete them."
      fi

      echo "Cleanup complete."
    else
      echo "Namespace $NAMESPACE does not exist."
    fi
  else
    echo "kubectl not found. Cannot perform cleanup."
  fi
  exit 0
fi

# Process tolerations
TOLERATIONS_YAML=""
for toleration in "${TOLERATION_ARRAY[@]}"; do
  # Split by colon: key:value:effect
  IFS=':' read -r key value effect <<<"$toleration"

  # Default effect to NoSchedule if not provided
  if [ -z "$effect" ]; then
    effect="NoSchedule"
  fi

  if [ -z "$TOLERATIONS_YAML" ]; then
    TOLERATIONS_YAML="      tolerations:"
  fi

  TOLERATIONS_YAML="$TOLERATIONS_YAML
      - key: \"$key\"
        value: \"$value\"
        effect: \"$effect\""
done

# If no tolerations were specified, use an empty string
if [ -z "$TOLERATIONS_YAML" ]; then
  TOLERATIONS_YAML="      # No tolerations specified"
fi

# Process node selector
NODE_SELECTOR_YAML=""
if [ -n "$NODE_SELECTOR" ]; then
  # Split by = to get key and value
  IFS='=' read -r key value <<<"$NODE_SELECTOR"
  NODE_SELECTOR_YAML="      nodeSelector:
        $key: \"$value\""
else
  NODE_SELECTOR_YAML="      # No node selector specified"
fi

# Prepare the configuration content based on user input
CONFIG_YAML=""
if [ -n "$CONFIG_FILE" ]; then
  # Check if the custom config file exists
  if [ ! -f "$CONFIG_FILE" ]; then
    echo "Error: Config file not found: $CONFIG_FILE"
    exit 1
  fi

  # Read the custom config file
  CONFIG_YAML=$(sed 's/^/    /' "$CONFIG_FILE")

else
  # Use the default config
  CONFIG_YAML="    log-level: ${LOG_LEVEL}
    stdout: /var/log/jibril/jibril.log
    stderr: /var/log/jibril/jibril.err
    profiler: false
    daemon: true
    cardinal: true
    extension:
      - jibril
      - config
      - data
    plugin:
      - jibril:hold
      - jibril:procfs
      - jibril:printers
      # - jibril:jbconfig
      # - jibril:pause
      - jibril:detect
      # - jibril:netpolicy:file=/etc/jibril/netpolicy.yaml
    printer:
      - jibril:printers:stdout:raw=true
    event:
      # Network policy.
      # - jibril:netpolicy:dropip
      # - jibril:netpolicy:dropdomain
      # Method: flows.
      - jibril:detect:flow
      # Method: file access.
      - jibril:detect:file_example
      - jibril:detect:auth_logs_tamper
      - jibril:detect:binary_self_deletion
      - jibril:detect:capabilities_modification
      - jibril:detect:code_modification_through_procfs
      - jibril:detect:core_pattern_access
      - jibril:detect:cpu_fingerprint
      - jibril:detect:credentials_files_access
      - jibril:detect:crypto_miner_files
      - jibril:detect:environ_read_from_procfs
      - jibril:detect:filesystem_fingerprint
      - jibril:detect:global_shlib_modification
      - jibril:detect:java_debug_lib_load
      - jibril:detect:java_instrument_lib_load
      - jibril:detect:machine_fingerprint
      - jibril:detect:os_fingerprint
      - jibril:detect:os_network_fingerprint
      - jibril:detect:os_status_fingerprint
      - jibril:detect:package_repo_config_modification
      - jibril:detect:pam_config_modification
      - jibril:detect:sched_debug_access
      - jibril:detect:shell_config_modification
      - jibril:detect:ssl_certificate_access
      - jibril:detect:sudoers_modification
      - jibril:detect:sysrq_access
      - jibril:detect:unprivileged_bpf_config_access
      # Method: execution.
      - jibril:detect:exec_example
      - jibril:detect:binary_executed_by_loader
      - jibril:detect:code_on_the_fly
      - jibril:detect:crypto_miner_execution
      - jibril:detect:data_encoder_exec
      - jibril:detect:denial_of_service_tools
      - jibril:detect:exec_from_unusual_dir
      - jibril:detect:file_attribute_change
      - jibril:detect:hidden_elf_exec
      - jibril:detect:interpreter_shell_spawn
      - jibril:detect:net_filecopy_tool_exec
      - jibril:detect:net_mitm_tool_exec
      - jibril:detect:net_scan_tool_exec
      - jibril:detect:net_sniff_tool_exec
      - jibril:detect:net_suspicious_tool_exec
      - jibril:detect:net_suspicious_tool_shell
      - jibril:detect:passwd_usage
      - jibril:detect:runc_suspicious_exec
      - jibril:detect:webserver_exec
      - jibril:detect:webserver_shell_exec
      # Method: network peers.
      - jibril:detect:adult_domain_access
      - jibril:detect:badware_domain_access
      - jibril:detect:dyndns_domain_access
      - jibril:detect:fake_domain_access
      - jibril:detect:gambling_domain_access
      - jibril:detect:piracy_domain_access
      - jibril:detect:plaintext_communication
      - jibril:detect:threat_domain_access
      - jibril:detect:tracking_domain_access
      - jibril:detect:vpnlike_domain_access
"
fi

# Create the Kubernetes YAML files
cat >/tmp/jibril-template.yaml <<EOF
apiVersion: v1
kind: ConfigMap
metadata:
  name: jibril-config
  namespace: ${NAMESPACE}
data:
  config.yaml: |
${CONFIG_YAML}

---
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: jibril
  namespace: ${NAMESPACE}
  labels:
    app: jibril
    component: security-agent
spec:
  selector:
    matchLabels:
      app: jibril
  template:
    metadata:
      labels:
        app: jibril
        component: security-agent
    spec:
${TOLERATIONS_YAML}
${NODE_SELECTOR_YAML}
      hostPID: true
      hostNetwork: true
      dnsPolicy: ClusterFirstWithHostNet
      hostIPC: true
      containers:
      - name: jibril
        image: ${IMAGE}
        imagePullPolicy: Always
        securityContext:
          privileged: true
          capabilities:
            add:
            - SYS_ADMIN
            - NET_ADMIN
            - SYS_PTRACE
            - SYS_RESOURCE
          runAsUser: 0
        resources:
          requests:
            memory: "${MEMORY_REQUEST}"
            cpu: "${CPU_REQUEST}"
          limits:
            memory: "${MEMORY_LIMIT}"
            cpu: "${CPU_LIMIT}"
        env:
        - name: GOGC
          value: "20"
        - name: LOG_LEVEL
          value: "${LOG_LEVEL}"
        - name: NODE_NAME
          valueFrom:
            fieldRef:
              fieldPath: spec.nodeName
        volumeMounts:
        - name: bpffs
          mountPath: /sys/fs/bpf
        - name: debugfs
          mountPath: /sys/kernel/debug
        - name: sysfs
          mountPath: /sys
          readOnly: true
        - name: procfs
          mountPath: /proc
          readOnly: true
        - name: log-volume
          mountPath: /var/log/jibril
        - name: jibril-config
          mountPath: /etc/jibril
        command:
        - "/bin/sh"
        - "-c"
        - |
          ulimit -l unlimited
          rm -f /sys/fs/bpf/jb_*
          mkdir -p /var/log/jibril
          exec /usr/bin/jibril --config /etc/jibril/config.yaml
      volumes:
      - name: bpffs
        hostPath:
          path: /sys/fs/bpf
          type: Directory
      - name: debugfs
        hostPath:
          path: /sys/kernel/debug
          type: Directory
      - name: sysfs
        hostPath:
          path: /sys
          type: Directory
      - name: procfs
        hostPath:
          path: /proc
          type: Directory
      - name: log-volume
        hostPath:
          path: /var/log/jibril
          type: DirectoryOrCreate
      - name: jibril-config
        configMap:
          name: jibril-config
EOF

# Save or apply the configuration
if [ "$DRY_RUN" = true ]; then
  # Print to stdout
  cat /tmp/jibril-template.yaml
  echo "YAML configuration printed (dry run)"
  exit 0
else
  # Save to output file
  cp /tmp/jibril-template.yaml "$OUTPUT_FILE"
  echo "Generated Kubernetes configuration saved to $OUTPUT_FILE"

  # Check if kubectl is available and user wants to apply config
  if command -v kubectl >/dev/null 2>&1; then
    read -rp "Do you want to apply this configuration to your Kubernetes cluster? (y/N): " confirm
    if [[ "$confirm" =~ ^[Yy]$ ]]; then
      # Create namespace if it doesn't exist
      if ! kubectl get namespace "$NAMESPACE" >/dev/null 2>&1; then
        echo "Creating namespace $NAMESPACE..."
        kubectl create namespace "$NAMESPACE"
      fi

      # Apply the configuration
      echo "Applying Jibril DaemonSet to namespace $NAMESPACE..."
      kubectl apply -f "$OUTPUT_FILE"
      echo "Deployment complete. To check status, run: kubectl -n $NAMESPACE get pods -l app=jibril"
    else
      echo "Configuration saved but not applied."
    fi
  else
    echo "kubectl not found. To apply this configuration manually, run: kubectl apply -f $OUTPUT_FILE"
  fi
fi
