apt-get -y update
apt-get -y install git
apt-get -y install virtualenv
git clone https://github.com/mukeshkhattar/bcra
cd bcra
virtualenv venv -p python3
source venv/bin/activate
pip install -r requirements.txt
cat gce_backend_app1.py |
  sed -e "s/YOUR_BACKEND_SERVICE_ID/$(gcloud compute backend-services describe network-a-us-west-1-backend --global --format="value(id)")/g" |
  sed -e "s/YOUR_PROJECT_ID/$(gcloud config get-value account | tr -cd "[0-9]")/g" > real_backend_app1.py
gunicorn real_backend_app1:app -b 0.0.0.0:80
