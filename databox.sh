#!/bin/sh

case "$1" in

"up") echo "Creating DataBox"
    # Get user from logged in username
    export DATABOX_USER=`whoami`

    # Launc Terraform passing that user as parameter
    terraform apply --var username=$DATABOX_USER

    # Get DataBox IP from state after the script completes
    export DATABOX_IP=`terraform output ec2_ip`

    # Run Ansible script using the above IP address
    ansible-playbook -i "$DATABOX_IP," -K playbooks/databox.yml -u ubuntu
    ;;
"down") echo  "Destroying DataBox"
    terraform destroy
    ;;
*)  echo "DataBox - create and destroy AWS instances for Data Science"
    echo "./databox.sh up - Create a DataBox"
    echo "./databox.sh down - Destroy the DataBox"
esac
