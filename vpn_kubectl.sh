# echo 'source /<common path for all users/vpn_kubectl.sh' >> ~/.bashrc

# Only load for intended users
case "$USER" in
  sandbox)     export K_PORT=8001 ;;
  user1) export K_PORT=8002 ;;
  user2)    export K_PORT=8003 ;;
  *)           return 0 ;;
esac

refresh_tunnel() {
  local PID_FILE="/tmp/k8s-proxy-$USER.pid"

  if [ -f "$PID_FILE" ]; then
    kill "$(cat "$PID_FILE")" 2>/dev/null
    rm -f "$PID_FILE"
  else
    lsof -ti tcp:"$K_PORT" | xargs kill -9 2>/dev/null
  fi

  setsid -f kubectl proxy --port="$K_PORT" --keepalive=5m > /dev/null 2>&1

  pgrep -n -f "kubectl proxy --port=$K_PORT" > "$PID_FILE"

  echo "✅ Tunnel established for: $(kubectl config current-context) [Port: $K_PORT]"
}

kubectx() {
  command kubectx "$@"
  refresh_tunnel
}

alias kubectl='kubecolor --server=http://localhost:$K_PORT'
