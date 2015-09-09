## Automate installation of OpenShift 
These scripts are intended to help automate installation of openshift (enterprise, or origin) onto an IaaS platform.
Initial spike is for installing on AWS EC2.


### AWS Credentials
To access AWS, terraform needs to know the secret keys and access keys for AWS. 
Create a file named terraform.tfvars in the root directory of this repo and assign the keys as such:

    aws_access_key = "FFFFFFFFFFFFFFFFFFFFFFF"
    aws_secret_key = "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF"
    aws_region = "us-east-1"

### RHN Subscription credentials
These scripts were tested to run on EC2 with a valid RHEL subscription. They most likely run on the AWS RHEL or CentOS7, but not tested yet.
To activate the RHEL subscription, create a file named `./ansible/rhel-sub-vars.yml` and add these values:

    username: FFFFF
    password: FFFFF
    pool_id: FFFFFFFFFFFFFFFFFFFFFFFFFFFFFF


