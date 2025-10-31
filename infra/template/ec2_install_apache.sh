# ! /bin/bash
# shellcheck disable=SC2164
# cd /home/ubuntu
# yes | sudo apt update
# yes | sudo apt install python3 python3-pip
# git clone https://github.com/darshanzatakiya/flask-app.git
# sleep 20
# # shellcheck disable=SC2164
# cd flask-app
# pip3 install -r requirements.txt
# echo 'Waiting for 30 seconds before running the app.py'
# setsid python3 -u app.py &
# sleep 30

#!/bin/bash
# shellcheck disable=SC2164

cd /home/ubuntu

# Update OS and install Python
yes | sudo apt update
yes | sudo apt install python3 python3-pip -y

# Stop previous Flask app if running
pkill -f app.py || true

# Remove old version and clone latest
rm -rf flask-app
git clone https://github.com/darshanzatakiya/flask-app.git
cd flask-app

# Install Python dependencies
pip3 install -r requirements.txt

# Start Flask app in background
setsid python3 -u app.py &

echo "✅ Flask app deployed successfully!"
sleep 30

