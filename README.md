# databox
Infrastructure as a code for Data Science processing machine

## Requirements

* Terraform
* Ansible
* An [SSH key added to the SSH agent](https://help.github.com/articles/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent/).

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

## Install Docker and other tools on the databox

```
ansible-playbook -i '35.177.7.160,' -K playbooks/databox.yml -u ubuntu
```

*Note:* the correct IP address that has been shown in the output must be used. *The IP address must be followed by a comma!*

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
