#!/bin/bash

while [[ $# -gt 1 ]]
do
key="$1"

case $key in
    -r|--region)
    REGION="$2"
    shift # past argument
    ;;
    -u|--username)
    USERNAME="$2"
    shift # past argument
    ;;
    -i|--instance)
    INSTANCE="$2"
    shift # past argument
    ;;
    -v|--volume_size)
    VOLUME_SIZE="$2"
    shift # past argument
    ;;
    -a|--ami_id)
    AMI_ID="$2"
    shift # past argument
    ;;
    -s|--snapshot_id)
    SNAPSHOT_ID="$2"
    shift # past argument
    ;;
    -p|--playbook)
    PLAYBOOK="$2"
    shift # past argument
    ;;
            # unknown option
    *)
    ;;
esac
shift # past argument or value
done

case "$1" in

"up") echo "Creating DataBox"
    # If I don't specify the region use a default value
    if [ -z "${REGION+x}" ]; then
        export REGION="eu-west-2"
    fi

    # If I don't specify the username get it from logged in user
    if [ -z "${USERNAME+x}" ]; then
        export USERNAME=`whoami`
    fi

    # If I don't specify the instance type use a default value
    if [ -z "${INSTANCE+x}" ]; then
        export INSTANCE="t2.micro"
    fi

    # If I don't specify the volume size use a default value
    if [ -z "${VOLUME_SIZE+x}" ]; then
        export VOLUME_SIZE="40"
    fi

    # If I don't specify the AMI id set it to empty string
    if [ -z "${AMI_ID+x}" ]; then
        export AMI_ID=""
    fi

    # If I don't specify the AMI id set it to empty string
    if [ -z "${SNAPSHOT_ID+x}" ]; then
        export SNAPSHOT_ID=""
    fi

    # If I don't specify a custom playback set it to the default: databox.yml
    if [ -z "${PLAYBOOK+x}" ]; then
        export PLAYBOOK="playbooks/databox.yml"
    fi
    # Launch Terraform passing that user as parameter
    terraform apply --var username=$USERNAME --var aws_region=$REGION --var instance_type=$INSTANCE --var volume_size=$VOLUME_SIZE --var ami_id=$AMI_ID --var snapshot_id=$SNAPSHOT_ID

    # Get DataBox IP from state after the script completes
    export DATABOX_IP=`terraform output ec2_ip`

    # Run Ansible script using the above IP address
    ansible-playbook -i "$DATABOX_IP," -K "$PLAYBOOK" -u ubuntu
    ;;
"down") echo  "Destroying DataBox"
    # If I don't specify the region use a default value
    if [ -z "${REGION+x}" ]; then
        export REGION="eu-west-2"
    fi

    # Get DataBox IP from state after the script completes
    export DATABOX_IP=`terraform output ec2_ip`
    
    # Run ansible teardown tasks
    ansible-playbook -i "$DATABOX_IP," -K playbooks/teardown.yml -u ubuntu
    
    terraform destroy --var aws_region=$REGION
    ;;
*)  echo "DataBox - create and destroy AWS instances for Data Science"
    echo "./databox.sh up - Create a DataBox"
    echo " -- options -- "
    echo "  -r|--region - AWS region"
    echo "  -u|--username - Username used to name the AWS objects"
    echo "  -i|--instance - AWS instance type"
    echo "  -v|--volume_size - EBS volume size"
    echo "  -a|--ami_id - AMI id"
    echo "  -p|--playbook - Ansible playbook for post deployment tasks"
    echo "  -s|--snapshot_id - Id of the snapshot from which to create volume"
    echo "./databox.sh down - Destroy the DataBox"
esac
