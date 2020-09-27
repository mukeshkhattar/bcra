## Architecture - https://cloud.google.com/network-connectivity/docs/vpn/images/ha-vpn-gcp-to-gcp.svg

### Services

The following services need to be enabled for the project:
```
gcloud services enable cloudresourcemanager.googleapis.com
gcloud services enable compute.googleapis.com
gcloud services enable dns.googleapis.com
gcloud services enable iam.googleapis.com
gcloud services enable iap.googleapis.com
gcloud services enable logging.googleapis.com
gcloud services enable monitoring.googleapis.com
```

## Create VPC and subnets in GCP Project
delete the default vpc

'''
gcloud compute firewall-rules delete default-allow-icmp default-allow-ssh default-allow-rdp default-allow-internal
gcloud compute networks delete default
gcloud compute networks create network-a --bgp-routing-mode=global --subnet-mode=custom
# The subnet below is for workloads
gcloud compute networks subnets create subnet-a-west \
    --network=network-a \
    --range=10.0.2.0/24 \
    --region=us-west1
# The subnet below is for VPN HA
gcloud compute networks subnets create subnet-a-central \
    --network=network-a \
    --range=10.0.1.0/24 \
    --region=us-central1
'''

# Add Router and NAT
This is needed so that VM can download the start script

```
gcloud compute routers create nat-router-a-west \
    --network=network-a \
    --region=us-west1

gcloud compute routers nats create nat-config-a-west \
    --router-region us-west1 \
    --router nat-router-a-west \
    --nat-all-subnet-ip-ranges \
    --auto-allocate-nat-external-ips

gcloud compute routers create nat-router-a-central \
    --network=network-a \
    --region=us-central1

gcloud compute routers nats create nat-config-a-central \
    --router-region us-central1 \
    --router nat-router-a-central \
    --nat-all-subnet-ip-ranges \
    --auto-allocate-nat-external-ips
```

## Create VM Instance template

gcloud compute instance-templates create bcra-instance-template-1 \
  --machine-type=e2-small \
  --network=network-a \
  --subnet=subnet-a-west \
  --region=us-west1 \
  --metadata=startup-script-url=gs://bcra-poc-medatadata/startup_script.sh \
  --scopes=compute-ro,storage-ro

## Create health check

gcloud compute health-checks create http my-health-check

## Create instance group
```
gcloud compute instance-groups managed create bcra-instance-group-1 \
 --size=3 \
 --template=bcra-instance-template-1 \
 --description=instance-group-1 \
 --health-check=my-health-check \
 --region=us-west1

```

## get SSL cert and upload it to GCP project

1. Create a VM .
```
Name: certbot-vm
Machine type: micro (f1-micro)
Access scopes:
Set access for each API
Compute Engine: Read/Write
Boot disk image:
Debian GNU/Linux 9 (stretch)
Firewall:
Allow HTTP traffic
Allow HTTPS traffic
```


2. Install a small web server on VM
```
  mkdir web
  cd web
  echo "Hello" > index.html
  sudo busybox httpd -v -f
```

3. Add DNS record pointing to above web server
```
Name/Host/Alias: @
Value: the External IP address of the VM you created to authenticate your domain ownership above.
TTL: the default for your registrar, or 86400 (one day).
```

4. Test the web server
Your web browser should display Hello

5. Create SSL cert
```
sudo pkill busybox
sudo apt-get install -y certbot
sudo certbot certonly --standalone -d mytsystemsinc.com
```

output:
```
- Congratulations! Your certificate and chain have been saved at:
   /etc/letsencrypt/live/mytsystemsinc.com/fullchain.pem
   Your key file has been saved at:
   /etc/letsencrypt/live/mytsystemsinc.com/privkey.pem
   Your cert will expire on 2020-12-25. To obtain a new or tweaked
   version of this certificate in the future, simply run certbot
   again. To non-interactively renew *all* of your certificates, run
   "certbot renew"
 - Your account credentials have been saved in your Certbot
   configuration directory at /etc/letsencrypt. You should make a
   secure backup of this folder now. This configuration directory will
   also contain certificates and private keys obtained by Certbot so
   making regular backups of this folder is ideal.
```

6. Add cert to project
```
gcloud compute ssl-certificates create my-cert --certificate=fullchain1.pem --private-key=privkey1.pem
```
output:
```
Created [https://www.googleapis.com/compute/v1/projects/bcra-poc-3/global/sslCertificates/my-cert].
NAME     TYPE          CREATION_TIMESTAMP             EXPIRE_TIME                    MANAGED_STATUS
my-cert  SELF_MANAGED  2020-09-26T13:36:51.217-07:00  2020-12-25T11:03:05.000-08:00
```

verify in console by navigating to load balancing-->advanced--> certificates

## Create Load balancer and point DNS record to it

use the steps below
https://cloud.google.com/iap/docs/tutorial-gce#step_4_create_a_load_balancer

## Point DNS recorde to LB IP address

## Restart Instance Group
This is needed so that backend service id is picked up by startup script

## Enable IAP
1. Create a firewall rule to allow traffic from IAP  IP ranges on tcp:80 on all instnaces in network-a
2. create oauth consent screen
3. Enable IAP through cloud console



## Running Tests
login with app-users - access denined
add app-users to IAP Secure webapp role AT PROJECT level
memebrs of app-users group can login now
login with mukeshkhattar@mytsystemsinc.com (admin)- access denined
add mukeshkhattar@mytsystemsinc.comto IAP Secure webapp role AT PROJECT level
mukeshkhattar@mytsystemsinc.com can login now

## Add access levels




