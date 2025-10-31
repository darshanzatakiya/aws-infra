# #! /bin/bash
# # shellcheck disable=SC2164
# cd /home/ubuntu
# yes | sudo apt update
# yes | sudo apt install python3 python3-pip
# git clone https://github.com/darshanzatakiya/aws-infra.git
# sleep 20
# # shellcheck disable=SC2164
# cd python-mysql-db-proj-1
# pip3 install -r requirements.txt
# echo 'Waiting for 30 seconds before running the app.py'
# setsid python3 -u app.py &
# sleep 30

#! /bin/bash
# Go to home directory



# cd /home/ubuntu || exit

# # Update and install Python & pip
# yes | sudo apt update
# yes | sudo apt install -y python3 python3-pip git

# # Install virtualenv (optional but recommended)
# pip3 install --user virtualenv

# # Clone your repo (skip if already cloned)
# if [ ! -d "aws-infra" ]; then
#     git clone https://github.com/darshanzatakiya/aws-infra.git
# fi

# # Navigate to your Flask app
# cd aws-infra/python-mysql-db-proj-1 || exit

# # Install dependencies
# pip3 install -r requirements.txt
# pip3 install gunicorn flask-cors  # ensure gunicorn & CORS installed

# # Kill any previous running Flask/Gunicorn process on port 5000
# fuser -k 5000/tcp

# # Run app with gunicorn in background
# nohup gunicorn -w 4 -b 0.0.0.0:5000 app:app > app.log 2>&1 &

# echo "Flask app is starting in background. Check app.log for output."


#!/bin/bash

# Go to home
cd /home/ubuntu

# Update and install dependencies
yes | sudo apt update
yes | sudo apt install -y python3 python3-pip git nginx

# Clone your repo (or pull if already exists)
if [ -d "aws-infra" ]; then
    cd aws-infra
    git pull
else
    git clone https://github.com/darshanzatakiya/aws-infra.git
    cd aws-infra
fi

# Go to your Flask app directory
cd python-mysql-db-proj-1

# Install Python dependencies
pip3 install --upgrade pip
pip3 install -r requirements.txt
pip3 install gunicorn

# Set permissions (optional)
sudo chown -R ubuntu:ubuntu /home/ubuntu/aws-infra

# Stop any existing Gunicorn processes
pkill gunicorn || true

# Run Flask app using Gunicorn in the background
nohup gunicorn -w 4 -b 0.0.0.0:8000 app:app > app.log 2>&1 &

# Configure Nginx as reverse proxy
sudo tee /etc/nginx/sites-available/flask_app <<EOF
server {
    listen 80;
    server_name _;

    location / {
        proxy_pass http://127.0.0.1:8000;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}
EOF

# Enable site and restart Nginx
sudo ln -sf /etc/nginx/sites-available/flask_app /etc/nginx/sites-enabled
sudo nginx -t
sudo systemctl restart nginx

echo "Flask app deployed successfully. Check your URL."
