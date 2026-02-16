# Add this to .bashrc
# 1. Define your environment-specific port here
# Sandbox: 8001 | Preprod: 8002 | Prod: 8003
export K_PORT=8003 

# 2. The Reusable Tunnel Manager
refresh_tunnel() {
    local PID_FILE="/tmp/k8s-proxy-$USER.pid"

    # Precise Kill using PID
    if [ -f "$PID_FILE" ]; then
        kill $(cat "$PID_FILE") > /dev/null 2>&1
        rm "$PID_FILE"
    else
        # Fallback Safety Catch
        fuser -k $K_PORT/tcp > /dev/null 2>&1
    fi

    # Start the tunnel silently in the background
    (command kubectl proxy --port=$K_PORT --keepalive=5m > /dev/null 2>&1 &)
    
    # Save the new PID
    echo $! > "$PID_FILE"

    echo "✅ Tunnel established for: $(command kubectl config current-context) [Port: $K_PORT]"
}

# 3. The Automation Wrapper
kubectx() {
    command kubectx "$@"
    refresh_tunnel
}

# 4. The Main Alias (using the global variable)
alias kubectl='kubecolor --server=http://localhost:$K_PORT'
