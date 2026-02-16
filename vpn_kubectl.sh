# Define the tunnel function in .bashrc
refresh_tunnel() {
    local PORT=8001 # Change this to 8002 or 8003 for your other users
    local PID_FILE="/tmp/k8s-proxy-$USER.pid"

    # 1. Precise Kill (PID)
    if [ -f "$PID_FILE" ]; then
        kill $(cat "$PID_FILE") > /dev/null 2>&1
        rm "$PID_FILE"
    fi

    # 2. Safety Catch (Port-based)
    # If something is still hanging on the port, fuser will clear it
    fuser -k $PORT/tcp > /dev/null 2>&1

    # 3. Start the new background tunnel
    kubectl proxy --port=$PORT --keepalive=5m & 
    echo $! > "$PID_FILE"

    echo "🚀 Tunnel established for: $(kubectl config current-context) on port $PORT"
}

# The kubectx wrapper
kubectx() {
    # Run the real kubectx tool first with whatever arguments you passed
    command kubectx "$@"
    
    # After the context switches, refresh the tunnel automatically
    refresh_tunnel
}

# Your clean alias
alias k='kubectl --server=http://localhost:8001'
