# Automate installation of OpenShift 
This repo contains [Ansible](http://docs.ansible.com) and [terraform](https://www.terraform.io) scripts for installing [openshift](https://enterprise.openshift.com) onto [OpenStack](http://www.redhat.com/en/insights/openstack) or AWS EC2.


The repo is organized into the different deployment models. Currently tested with EC2 and OpenStack, but can be extended to Google Compute, Digital Ocean, etc. Happy to take pull requests for additional infrastructure.

## Getting started

There are a few pre-requisites for these scripts:

* terraform >v0.6.3 
* ansible >1.9.2
* git


To get started, use git to pull down this repo. You'll also want to clone down the [openshift-ansible installer](https://github.com/openshift/openshift-ansible) as that's used to do the actual deployment of openshift (which is awesome by the way!). This project also used the [terraform.py] (https://github.com/CiscoCloud/terraform.py) to create an Ansible invetory from the Terraform files.
For this getting started section, let's assume the directory structure looks like this:

    ./openshift-terraform-ansible/
    ./openshift-ansible/
    ./terraform.py/
    
You'll need to fill in some credentials for the different environments that you use. There are two files that need to be updated: the terraform credentials and the RHEL subscription credentials (NOTE: you need RHEL to install OpenShift Enterprise. If you're just installing Origin, then you don't need a subscription -- ie, can just use Fedora)

### AWS Credentials
To access AWS, terraform needs to know the secret keys and access keys for AWS. 
Create a file named `terraform.tfvars` in the `ec2` directory of this repo and assign the keys as such:

    aws_access_key = "FFFFFFFFFFFFFFFFFFFFFFF"
    aws_secret_key = "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF"
    aws_region = "us-east-1"
    aws_availability_zone = "us-east-1c"
    security_group = "aws-sec-group"
    keypair = "yourkey"
    master_instance_type = "c3.2xlarge"
    node_instance_type = "c3.xlarge"
    num_nodes = "5"
    
### Openstack Credentials
To access OpenStack, terraform needs to know the secret keys and access keys for your OpenStack deployment. 
Create a file named `terraform.tfvars` in the `openstack` directory of this repo and assign the keys as such:

    openstack_user_name = "username"
    openstack_tenant_name = "tenant anme"
    openstack_tenant_id = "tentat-id"
    openstack_password = "password"
    openstack_auth_url = "http://youropenstack.com:5000/v2.0"
    openstack_availability_zone = "nova"
    openstack_region = "region"
    openstack_keypair = "keypair"
    num_nodes = "1"
    
    # update these to the image IDs you want to use in your infra
    master_image_id = "6b7a5472-5187-4e38-bce4-9d6d2a11a8e7"
    master_instance_size = "m1.large"
    
    node_image_id = "6b7a5472-5187-4e38-bce4-9d6d2a11a8e7"
    node_instance_size = "m1.large"

### GCE Credentials
To access GCE, terraform needs to know the secret keys and access keys for your GCE account. 
Create a file named `terraform.tfvars` in the `gce` directory of this repo and assign the keys as such:

    gce_access_key = "myuser: ssh-dss AAA<long string - the public key of the user you will use to connect on the server later>szSHlg== myuser@myserver"
    gce_region = "us-east1"
    gce_project = "<your project name on GCE (top right corner of the console)>"
    num_nodes = "2"

In addition of AWS and OpenStack procedure Google require another extra file which contains the credential information. Terraform use the GCE service account to communicate with GCE and thus you need to have a GCE account file on the ./gce directory (you can simply download it from GCE). You can find more information about this step directly on Teraform documentation here : https://www.terraform.io/docs/providers/google/index.html

Here is my account file as example:

[mysuer@myserver gce]$ cat account.json
{
  "type": "service_account",
  "project_id": "<your project id>",
  "private_key_id": "b...<short string>...3",
  "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvQIBADAN...<very very long string>...SFG35w=\n-----END PRIVATE KEY-----\n",
  "client_email": "49...o@developer.gserviceaccount.com",
  "client_id": "49...o.apps.googleusercontent.com",
  "auth_uri": "https://accounts.google.com/o/oauth2/auth",
  "token_uri": "https://accounts.google.com/o/oauth2/token",
  "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
  "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/4...0developer.gserviceaccount.com"
}


### RHN Subscription credentials
These scripts were tested to run on EC2 with a valid RHEL subscription. They most likely run on the AWS RHEL or CentOS7, but not tested yet.
To activate the RHEL subscription, create a file in the `./<provider>/ansible` directory named `rhel-sub-vars.yml` and add these values where `provider` is `ec2` or `openstack`

    username: FFFFF
    password: FFFFF
    pool_id: FFFFFFFFFFFFFFFFFFFFFFFFFFFFFF

Once you've set up the credentials files, you'll be ready to set up openshift

## Deploy OpenShift

Deploying involves creating the infrastructure (networks, compute instances, IPs, security groups, etc), prepping the install as [advised by the openshift documentation](https://docs.openshift.org/latest/install_config/install/prerequisites.html), and then installing openshift itself.

### Deploy the infrastructure
To deploy the infrastructure, navigate to the `ec2` or `openstack` folder that you wish to use and check the status of the infrastructure (ie, kinda like a test run, and see the components that will be created):

    terraform plan
    
If everything looks good, then you can go ahead and create the infrastructure:

    terraform apply
    
If this completes successfully, then yay! You should go to the next step to prep the infrastructure

### Connect up your RHEL subscription (optional)
This is an optional step but recommended if you're using RHEL. Run the following ansible script to attach your RHEL subscription to all of the nodes/compute instances created above:

    ansible-playbook -i ../../terraform.py/terraform.py ./ansible/rhel-sub.yml --private-key=/location/to/private/keys

### Prep your environment
To prep the environment (downnload docker, set up repos, etc) run the following playbook:

    ansible-playbook -i ../../terraform.py/terraform.py ./ansible/ose3-prep-nodes.yml --private-key=/location/to/private/keys
    
### Run the OpenShift installer
To run the openshift installer, you'll first need to create the inventory file. Unfortunately this step is a bit manual until I hack the terraform.py scripts to generate this on the fly based on metadata/tags. 

Create the inventory file; you can [use this example to get an idea of what to configure](./example-inventory). You can tweak the settings, and you MUST add the DNS/IP addresses of your servers. This is the part that's not automated yet :)

Once you've got your inventory scripts, you can run this ansible playbook:

    ansible-playbook -i ./inventory --private-key=/location/to/private/keys ../../openshift-ansible/playbooks/byo/config.yml
    
    
Congrats! You've got an openshift cluster!
     
Now run this script to set up the registry/router/etc:
     
    sudo su -
    export INTERNAL_HOSTNAME=$(hostname -f)
    sh <(curl -s -L https://gist.github.com/christian-posta/dbabd26005989bafab98/raw) $INTERNAL_HOSTNAME 