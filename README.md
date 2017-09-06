# databox
Infrastructure as a code for Data Science processing machine

## Requirements

* Aws cli (you will need to configure a profile with `aws configure --profile gds-data`. For this you will need an aws access key with the relevant permissions against your IAM account)
* Terraform
* Ansible (note that ansible requires python 2.7, so it would be best to set this up as a virtual environment using virtualenv)
* An [SSH key added to the SSH agent](https://help.github.com/articles/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent/).

## Create the AWS infrastructure

### Using the databox.sh wrapper

#### Create the databox

The bash script `databox.sh` wraps the terraform and ansible process, so that you can simply run the following to get started:

```./databox.sh up```

This will use the default settings which are:

|flag|variable|default|
|---|---|---|
|-r|aws_region|eu-west-2 (london)|
|-i|instance_type|t2.micro. A list of other available instance types can be found [here](https://aws.amazon.com/ec2/instance-types/)|
|-u|username|A lookup will be performed using the bash command `whoami`|

*NOTE: Ansible will require you to enter your local sudo password before continuing.*

#### Connecting to your databox

At the end of the process an IP address will be output like this:

```
Apply complete! Resources: 6 added, 0 changed, 0 destroyed.

Outputs:

ec2_ip = 35.177.7.160
```
To log into this machine take this address and run:

```
ssh ubuntu@35.177.7.160
```

You can test that Docker is up and running with:

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

#### Destroying the databox

The resources can later be destroyed with:

```
./databox.sh down
```

You can use the arguments in the table above to customise your databox, for example:

```
./databox.sh -r eu-west-1 -i c4.2xlarge 
```

It should not usually be necessary to specify a username using `-u` unless you are running multiple databox, in which case it is required (this is not recommended).

Note that if you create a databox by specifying region this way, you must also pass the region (`-r`) variable to the `./databox.sh down` command:

```
./databox.sh -r eu-west-1
```

*NOTE: Failing to pass the correct region argument to the `./databox.sh down` command will result in your resources not being found, and consequently, not destroyed.*

### Using terraform and ansible directly

If you need additional customisations, the following commands can be run without the `./databox.sh` wrapper:

#### Setting up a databox

To create resources with the default settings:

```
terraform apply
```

at the end it will output and IP address like this:

```
Apply complete! Resources: 6 added, 0 changed, 0 destroyed.

Outputs:

ec2_ip = 35.177.7.160
```

Variable arguments can be passed to terraform with `--var`, for example:

```
terraform apply --var username=user --var aws_region=eu-west-1 --var instance_type=c4.2xlarge
```

#### Install Docker and other tools on the databox

```
ansible-playbook -i '35.177.7.160,' -K playbooks/databox.yml -u ubuntu
```

*Note:* the correct IP address that has been shown in the output must be used. *The IP address must be followed by a comma!*

#### Connect to the databox

As with the `./databox.sh` wrapper, you will need to connect to the databox with:

```
ssh ubuntu@35.177.7.160
```

#### Destroy the created databox on AWS

```
terraform destroy
```

As before, if you specified a region in `terraform apply --var aws_region=...` you must specify the same region in `terraform destroy --var aws_region=...` otherwise the resources you created will not be found.

## Copying data to and from a databox with scp

To transfer data to and from your local machine you can use [scp](https://en.wikipedia.org/wiki/Secure_copy).
SCP uses the same authentication mechanism as SSH, so if you have followed the above steps, it should be very easy!

#### Uploading data to the databox

From the local machine (replacing 0.0.0.0 with the actual IP of your databox:

```
# Create a folder in which to store input data

ssh ubuntu@0.0.0.0 'mkdir -p /home/ubuntu/govuk-lda-tagger-image/input'

# Secure copy input_data.csv from local to the newly created input folder

scp input_data.csv ubuntu@0.0.0.0:/home/ubuntu/govuk-lda-tagger-image/input/input_data.csv
```

#### Downloading data to your local machine

From the local machine (again replacing 0.0.0.0 with the actual IP of the remote machine):

```

# Specifying `-r` allows a recursive copy of the whole folder

scp -r ubuntu@0.0.0.0:/home/ubuntu/govuk-lda-tagger-image/output ./
```

