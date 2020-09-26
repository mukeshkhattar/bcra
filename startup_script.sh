apt-get -y update
apt-get -y install git
apt-get -y install virtualenv
git clone https://github.com/mukeshkhattar/bcra
cd bcra
virtualenv venv -p python3
source venv/bin/activate
pip install -r requirements.txt
cat gce_backend.py |
  sed -e "s/YOUR_BACKEND_SERVICE_ID/$(gcloud compute backend-services describe my-backend-service --global --format="value(id)")/g" |
  sed -e "s/YOUR_PROJECT_ID/$(gcloud config get-value account | tr -cd "[0-9]")/g" > real_backend.py
gunicorn real_backend:app -b 0.0.0.0:80
