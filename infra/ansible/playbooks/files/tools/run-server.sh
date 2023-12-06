if [[ -v PORT ]]; then
  echo "PORT is undefined"
  exit 1
fi

if [[ -v NAME ]]; then
  echo "NAME is undefined"
  exit 1
fi

if [ ! -f /uploaded_models/$NAME ]; then
  echo "Model not found!"
  exit 1
fi

SERVICE_NAME=server-$PORT.service

if [ ! -f /etc/systemd/system/$SERVICE_NAME ]; then
  touch /etc/systemd/system/$SERVICE_NAME
fi

TEMPLATE=$(cat /neuralearn/tools/server.template.service)

echo "$TEMPLATE" | sed "s/__PORT__/$PORT/g" | sed "s/__NAME__/$NAME/g" > /etc/systemd/system/$SERVICE_NAME

if [ systemctl is-active --quiet service ]; then
  systemctl restart $SERVICE_NAME
else
  systemctl daemon-reload
  systemctl enable $SERVICE_NAME
  systemctl start $SERVICE_NAME
fi
