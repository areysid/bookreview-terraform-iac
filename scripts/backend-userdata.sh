#!/bin/bash
set -euxo pipefail

export DEBIAN_FRONTEND=noninteractive

DB_HOST="${db_host}"
DB_USER="${db_user}"
DB_PASS="${db_pass}"
DB_NAME="${db_name}"
PUBLIC_ALB_DNS="${public_alb_dns}"

exec > >(tee /var/log/backend-user-data.log | logger -t user-data -s 2>/dev/console) 2>&1

echo "========================================"
echo "Updating system..."
echo "========================================"
apt update && apt upgrade -y

echo "========================================"
echo "Installing Node.js and dependencies..."
echo "========================================"
curl -fsSL https://deb.nodesource.com/setup_lts.x | bash -
apt install -y nodejs mysql-client nginx git

echo "========================================"
echo "Cloning project..."
echo "========================================"
if [ -d "/home/ubuntu/book-review-app" ]; then
  cd /home/ubuntu/book-review-app
  git pull
else
  git clone https://github.com/pravinmishraaws/book-review-app.git /home/ubuntu/book-review-app
fi

chown -R ubuntu:ubuntu /home/ubuntu/book-review-app

cd /home/ubuntu/book-review-app/backend

echo "========================================"
echo "Installing backend dependencies..."
echo "========================================"
sudo -u ubuntu npm install

echo "========================================"
echo "Creating .env file..."
echo "========================================"
cat > .env <<EOF
DB_HOST=${db_host}
DB_PORT=3306
DB_USER=${db_user}
DB_PASS=${db_pass}
DB_NAME=${db_name}
DB_DIALECT=mysql

PORT=3001

JWT_SECRET=mysecret

ALLOWED_ORIGINS=http://${public_alb_dns}
EOF

chown ubuntu:ubuntu .env

echo "========================================"
echo "Testing DB connection..."
echo "========================================"

until mysql -h "$DB_HOST" -P 3306 -u "$DB_USER" -p"$DB_PASS" -e "SELECT 1" > /dev/null 2>&1; do
  echo "Waiting for DB..."
  sleep 5
done
echo "DB is reachable!"

echo "========================================"
echo "Installing PM2..."
echo "========================================"
npm install -g pm2

echo "========================================"
echo "Starting backend..."
echo "========================================"
sudo -u ubuntu pm2 start src/server.js --name bk-backend --watch
sudo -u ubuntu pm2 save

env PATH=$PATH:/usr/bin pm2 startup systemd -u ubuntu --hp /home/ubuntu || true

echo "========================================"
echo "Deployment complete"
echo "========================================"
sudo -u ubuntu pm2 status