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
#! /bin/bash
# ------------------------------
# Automated setup for Flask app
# ------------------------------

# Move to home directory
cd /home/ubuntu

# Update packages
yes | sudo apt update
yes | sudo apt upgrade -y

# Install Python3, pip, git, and virtualenv
yes | sudo apt install python3 python3-pip git python3-venv -y

# Install Nginx
yes | sudo apt install nginx -y

# Clone the Flask app repo (or pull if already exists)
if [ -d "flask-app" ]; then
    cd flask-app
    git pull
else
    git clone https://github.com/darshanzatakiya/flask-app.git
    cd flask-app
fi

# Set up Python virtual environment
python3 -m venv venv
source venv/bin/activate

# Install Python dependencies
pip install --upgrade pip
pip install -r requirements.txt

# ------------------------------
# Run Flask app with Gunicorn
# ------------------------------
# Create systemd service to manage app
SERVICE_FILE=/etc/systemd/system/flask-app.service

sudo bash -c "cat > $SERVICE_FILE" <<EOL
[Unit]
Description=Gunicorn instance to serve Flask app
After=network.target

[Service]
User=ubuntu
Group=www-data
WorkingDirectory=/home/ubuntu/flask-app
Environment="PATH=/home/ubuntu/flask-app/venv/bin"
ExecStart=/home/ubuntu/flask-app/venv/bin/gunicorn --workers 3 --bind 0.0.0.0:8000 app:app

[Install]
WantedBy=multi-user.target
EOL

# Reload systemd and start the service
sudo systemctl daemon-reload
sudo systemctl start flask-app
sudo systemctl enable flask-app

# ------------------------------
# Configure Nginx to proxy requests
# ------------------------------
NGINX_FILE=/etc/nginx/sites-available/flask-app

sudo bash -c "cat > $NGINX_FILE" <<EOL
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
EOL

# Enable Nginx site and restart Nginx
sudo ln -sf /etc/nginx/sites-available/flask-app /etc/nginx/sites-enabled
sudo nginx -t
sudo systemctl restart nginx

echo "Deployment completed! Your Flask app should be available on port 80."
