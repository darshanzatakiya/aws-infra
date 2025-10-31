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
cd /home/ubuntu || exit

# Update and install Python & pip
yes | sudo apt update
yes | sudo apt install -y python3 python3-pip git

# Install virtualenv (optional but recommended)
pip3 install --user virtualenv

# Clone your repo (skip if already cloned)
if [ ! -d "aws-infra" ]; then
    git clone https://github.com/darshanzatakiya/aws-infra.git
fi

# Navigate to your Flask app
cd aws-infra/python-mysql-db-proj-1 || exit

# Install dependencies
pip3 install -r requirements.txt
pip3 install gunicorn flask-cors  # ensure gunicorn & CORS installed

# Kill any previous running Flask/Gunicorn process on port 5000
fuser -k 5000/tcp

# Run app with gunicorn in background
nohup gunicorn -w 4 -b 0.0.0.0:5000 app:app > app.log 2>&1 &

echo "Flask app is starting in background. Check app.log for output."
