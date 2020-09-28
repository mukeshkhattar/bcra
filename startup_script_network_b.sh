apt-get -y update
apt-get -y install git
apt-get -y install virtualenv
git clone https://github.com/mukeshkhattar/bcra
cd bcra
virtualenv venv -p python3
source venv/bin/activate
pip install -r requirements.txt
cat gce_backend_app2.py |
  sed -e "s/YOUR_BACKEND_SERVICE_ID/7800251586328008522/g" |
  sed -e "s/YOUR_PROJECT_ID/879485753866/g" > real_backend_app2.py
gunicorn real_backend_app2:app -b 0.0.0.0:80


