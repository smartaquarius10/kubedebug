#!/bin/sh

# Drop to non-root user if running as root
if [ "$(id -u)" = "0" ]; then
  echo "Switching to non-root user 'debuguser'..."
  exec su-exec debuguser /bin/sh
else
  exec "$@"
fi
