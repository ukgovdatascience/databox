# databox
Infrastructure as a code for Data Science processing machine

## Requirements

* Terraform
* Ansible

## Create the AWS infrastructure

```
terraform apply
```

at the end it will output and IP address like this:

```
Apply complete! Resources: 6 added, 0 changed, 0 destroyed.

Outputs:

ec2_ip = 35.177.7.160
```

### Changing region and instance types

Different tasks will require different [instance](https://aws.amazon.com/ec2/instance-types/) types. 
However, some instance types are not available in each region, so it may be necessary to change region.
Instance type and region can thus be set as arguments along with `terraform apply`:

```
terraform apply --var username=user --var aws_region=eu-west-1 --var instance_type=c4.2xlarge
```

## Install Docker and other tools on the databox

```
ansible-playbook -i '35.177.7.160,' -K playbooks/databox.yml -u ubuntu
```

*Note:* the correct IP address that has been shown in the output must be used

## Connect to the databox

```
ssh ubuntu@35.177.7.160
```

### Test that Docker is up and running

```
ubuntu@ip-172-31-9-43:~$ docker version
Client:
 Version:      17.06.1-ce
 API version:  1.30
 Go version:   go1.8.3
 Git commit:   874a737
 Built:        Thu Aug 17 22:51:12 2017
 OS/Arch:      linux/amd64

Server:
 Version:      17.06.1-ce
 API version:  1.30 (minimum version 1.12)
 Go version:   go1.8.3
 Git commit:   874a737
 Built:        Thu Aug 17 22:50:04 2017
 OS/Arch:      linux/amd64
 Experimental: false
```

## Destroy the created databox on AWS

```
terraform destroy
```
