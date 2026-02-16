# Add this to .bashrc
# 1. Define your environment-specific port here
# Sandbox: 8001 | Preprod: 8003 | Prod: 8002
export K_PORT=8001

refresh_tunnel() {
    local PID_FILE="/tmp/k8s-proxy-$USER.pid"

    # Kill previous proxy safely (not a bash job)
    if [ -f "$PID_FILE" ]; then
        kill "$(cat "$PID_FILE")" 2>/dev/null
        rm -f "$PID_FILE"
    else
        lsof -ti tcp:"$K_PORT" | xargs kill -9 2>/dev/null
    fi

    # Start fully detached (no bash job control)
    setsid -f kubectl proxy --port="$K_PORT" --keepalive=5m \
        > /dev/null 2>&1

    # Save PID safely
    pgrep -n -f "kubectl proxy --port=$K_PORT" > "$PID_FILE"

    echo "✅ Tunnel established for: $(kubectl config current-context) [Port: $K_PORT]"
}

kubectx() {
    command kubectx "$@"
    refresh_tunnel
}

alias kubectl='kubecolor --server=http://localhost:$K_PORT'
