#!/bin/bash
set -euxo pipefail

export DEBIAN_FRONTEND=noninteractive

PUBLIC_ALB_DNS="${public_alb_dns}"
INTERNAL_ALB_DNS="${internal_alb_dns}"

APP_DIR="/home/ubuntu/book-review-app"
FRONTEND_DIR="$APP_DIR/frontend"
NGINX_CONF="/etc/nginx/sites-available/book-review"

exec > >(tee /var/log/frontend-user-data.log | logger -t user-data -s 2>/dev/console) 2>&1

echo "===== Updating system ====="
apt update && apt upgrade -y

echo "===== Installing Node, Nginx, Git ====="
curl -fsSL https://deb.nodesource.com/setup_lts.x | bash -
apt install -y nodejs nginx git

echo "===== Cloning repo ====="
if [ -d "$APP_DIR" ]; then
  cd "$APP_DIR"
  git pull
else
  git clone https://github.com/pravinmishraaws/book-review-app.git "$APP_DIR"
fi

chown -R ubuntu:ubuntu "$APP_DIR"
cd "$FRONTEND_DIR"

echo "===== Installing dependencies ====="
sudo -u ubuntu npm install

echo "===== Setting frontend env ====="
cat > .env.local <<EOF
NEXT_PUBLIC_API_URL=/api
EOF

chown ubuntu:ubuntu .env.local

echo "===== Building frontend ====="
sudo -u ubuntu npm run build

echo "===== Starting frontend with PM2 ====="
npm install -g pm2
sudo -u ubuntu pm2 delete frontend || true
sudo -u ubuntu pm2 start npm --name frontend -- start
sudo -u ubuntu pm2 save

env PATH=$PATH:/usr/bin pm2 startup systemd -u ubuntu --hp /home/ubuntu || true

echo "===== Configuring Nginx ====="
cat > "$NGINX_CONF" <<EOF
server {
    listen 80;
    server_name _;

    location /api/ {
        proxy_pass http://${internal_alb_dns}:3001;
        proxy_http_version 1.1;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    }

    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host \$host;
        proxy_cache_bypass \$http_upgrade;
    }
}
EOF

ln -sf /etc/nginx/sites-available/book-review /etc/nginx/sites-enabled/book-review
rm -f /etc/nginx/sites-enabled/default

echo "===== Testing Nginx ====="
nginx -t

echo "===== Restarting Nginx ====="
systemctl enable nginx
systemctl restart nginx

echo "===== Deployment complete ====="
sudo -u ubuntu pm2 status