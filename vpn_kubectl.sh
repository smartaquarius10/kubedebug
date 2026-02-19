# /etc/profile.d/k8s-tunnel.sh
# ps -ef|grep kubectl|awk '{print $2}'|xargs -I{} sudo kill {}

# Only load for intended users
case "$USER" in
  vagrant)     export K_PORT=8001 ;;
  smp-preprod) export K_PORT=8002 ;;
  smp-prod)    export K_PORT=8003 ;;
  *)           return 0 2>/dev/null || exit 0 ;;
esac


refresh_tunnel() {
  local PID_FILE="/tmp/k8s-proxy-$USER.pid"
  local KEEPALIVE_PID_FILE="/tmp/k8s-keepalive-$USER.pid"

  # Kill previous proxy
  if [ -f "$PID_FILE" ]; then
    kill "$(cat "$PID_FILE")" 2>/dev/null
    rm -f "$PID_FILE"
  else
    lsof -ti tcp:"$K_PORT" | xargs kill -9 2>/dev/null
  fi

  # Kill previous keepalive loop
  if [ -f "$KEEPALIVE_PID_FILE" ]; then
    kill "$(cat "$KEEPALIVE_PID_FILE")" 2>/dev/null
    rm -f "$KEEPALIVE_PID_FILE"
  fi

  # Start proxy (fully detached)
  setsid -f kubectl proxy --port="$K_PORT" --keepalive=5m > /dev/null 2>&1

  # Save proxy PID
  pgrep -n -f "kubectl proxy --port=$K_PORT" > "$PID_FILE"

  # Start keepalive loop
  (
    while sleep 600; do
      curl -s http://localhost:$K_PORT/healthz >/dev/null 2>&1
    done
  ) &
  echo $! > "$KEEPALIVE_PID_FILE"

  echo "✅ Tunnel established for: $(kubectl config current-context) [Port: $K_PORT]"
}


kubectxt() {
  command kubectx "$@" && refresh_tunnel
}


#alias k='kubecolor --server=http://localhost:$K_PORT'

k() {
  kubecolor --server="http://localhost:$K_PORT" "$@"
}

# Create a file  /usr/local/bin/k
#!/usr/bin/env bash
#source ~/WSL/k8s-tunnel.sh
#k "$@"
# this will make k available everywhere like watch command or custom shell scripts
