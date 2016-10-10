
# setup

at the moment of writing ansible runs only on python 2.7 

     $ pip install -r requirements.txt
     
install [packer.io](https://www.packer.io/)

configure `~/.aws/credentials`

build the ami:

    $ packer build packer-ml.ami-builder.json


# notes to self

## some commands

```
ansible-playbook aws.yml --extra-vars 'spot_price=0.005' 
while true; do aws ec2 describe-instances --filters Name=instance-state-name,Values=running ; sleep 10 ; done
while true; do date && aws ec2 describe-instances --filters Name=instance-state-name,Values=running | grep InstanceId ; sleep 10 ; done
aws ec2 terminate-instances --instance-ids i-9045071a i-09450783 i-a14a082b

aws ec2 cancel-spot-instance-requests --spot-instance-request-ids sir-01hdsk0k
aws ec2 describe-spot-instance-requests

check this to know if the instance is going to be terminated
wget -q -O- http://169.254.169.254/latest/meta-data/spot/termination-time


ansible-playbook tasks.yml --step --start-at-task='task name'


quick check of the installation:
THEANO_FLAGS='floatX=float32,device=gpu0,lib.cnmem=1' python3 anaconda3/lib/python3.5/site-packages/theano/misc/check_blas.py 
python -c 'import cv2; print(cv2.__version__)'
```



## dinamic inventory

http://docs.ansible.com/ansible/intro_dynamic_inventory.html#example-aws-ec2-external-inventory-script

at the moment of writing we have to have a copy of this script

```
$ wget https://raw.githubusercontent.com/ansible/ansible/devel/contrib/inventory/ec2.py \
       https://raw.githubusercontent.com/ansible/ansible/devel/contrib/inventory/ec2.ini && \
    chmod +x ec2.py
```

then in the ansible config:

    inventory = ./ec2.py

and how we can write `hosts=ec2` or `hosts=tag_whatever`

example output, to see what it does:

```
$ ./ec2.py
{
  "_meta": {
    "hostvars": {
      "52.49.182.41": {
        "ansible_ssh_host": "52.49.182.41", 
        "ec2_id": "i-963f7c1c", 
        "ec2_image_id": "ami-971a65e0", 
        "ec2_instanceLifecycle": "spot", 
        "ec2_ip_address": "52.49.182.41", 
        "ec2_public_dns_name": "ec2-52-49-182-41.eu-west-1.compute.amazonaws.com", 
        "ec2_spot_instance_request_id": "sir-01h71cjr",
        ...
        ...
      }
    }
  }, 
  "ec2": [
    "52.49.182.41"
  ], 
  "eu-west-1": [
    "52.49.182.41"
  ], 
  "eu-west-1b": [
    "52.49.182.41"
  ], 
  "tag_none": [
    "52.49.182.41"
  ],
  ...
  ...
}
```



# create an aws ami with packer.io

this is essentially the same as fire up an instance, run an ansible playbook on it, stop the instance and create a snapshot, then register it as an ami

```
$ packer build packer-ansible.json
amazon-ebs output will be in this color.

==> amazon-ebs: Prevalidating AMI Name...
==> amazon-ebs: Inspecting the source AMI...
==> amazon-ebs: Creating temporary keypair: packer 57411e14-5900-3043-3a3f-28a7f3a7d10a
==> amazon-ebs: Creating temporary security group for this instance...
==> amazon-ebs: Authorizing access to port 22 the temporary security group...
==> amazon-ebs: Launching a source AWS instance...
    amazon-ebs: Instance ID: i-6cbb31e0
==> amazon-ebs: Waiting for instance (i-6cbb31e0) to become ready...
==> amazon-ebs: Waiting for SSH to become available...
==> amazon-ebs: Connected to SSH!
==> amazon-ebs: Provisioning with Ansible...
==> amazon-ebs: SSH proxy: serving on 127.0.0.1:50808
==> amazon-ebs: Executing Ansible: ansible-playbook /Users/alex/workspace.some-code/aws/install-docker.yml -i /var/folders/hd/3pg3z_n51ln1j0p3gpqz1n8c0000gn/T/packer-provisioner-ansible180750730 --private-key /var/folders/hd/3pg3z_n51ln1j0p3gpqz1n8c0000gn/T/ansible-key122708759
    amazon-ebs:
    amazon-ebs: PLAY [ec2] *********************************************************************
    amazon-ebs:
    amazon-ebs: TASK [setup] *******************************************************************
    amazon-ebs: SSH proxy: accepted connection
==> amazon-ebs: authentication attempt from 127.0.0.1:50809 to 127.0.0.1:50808 as alex using none
==> amazon-ebs: unauthorized key
==> amazon-ebs: authentication attempt from 127.0.0.1:50809 to 127.0.0.1:50808 as alex using publickey
==> amazon-ebs: authentication attempt from 127.0.0.1:50809 to 127.0.0.1:50808 as alex using publickey
==> amazon-ebs: starting sftp subsystem
    amazon-ebs: ok: [default]
    amazon-ebs:
    amazon-ebs: TASK [make sure we have certs and https] ***************************************
==> amazon-ebs: starting sftp subsystem
    amazon-ebs: ok: [default]
    amazon-ebs:
    amazon-ebs: TASK [add key] *****************************************************************
==> amazon-ebs: starting sftp subsystem
    amazon-ebs: changed: [default]
    amazon-ebs:
    amazon-ebs: TASK [add repo to sources.list] ************************************************
==> amazon-ebs: starting sftp subsystem
    amazon-ebs: changed: [default]
    amazon-ebs:
    amazon-ebs: TASK [install docker] **********************************************************
==> amazon-ebs: starting sftp subsystem
    amazon-ebs: changed: [default]
    amazon-ebs:
    amazon-ebs: TASK [start docker daemon] *****************************************************
==> amazon-ebs: starting sftp subsystem
    amazon-ebs: ok: [default]
    amazon-ebs:
    amazon-ebs: TASK [add the docker group] ****************************************************
==> amazon-ebs: starting sftp subsystem
    amazon-ebs: ok: [default]
    amazon-ebs:
    amazon-ebs: TASK [add admin to the docker group] *******************************************
==> amazon-ebs: starting sftp subsystem
    amazon-ebs: changed: [default]
    amazon-ebs:
    amazon-ebs: TASK [install docker-compose] **************************************************
==> amazon-ebs: starting sftp subsystem
    amazon-ebs: changed: [default]
    amazon-ebs:
    amazon-ebs: TASK [make sure docker-compose owner is root:root, 0755] ***********************
==> amazon-ebs: starting sftp subsystem
    amazon-ebs: changed: [default]
    amazon-ebs:
    amazon-ebs: TASK [add a user, which can run docker containers] *****************************
==> amazon-ebs: starting sftp subsystem
    amazon-ebs: changed: [default]
    amazon-ebs:
    amazon-ebs: TASK [add key of the user to authorized_keys] **********************************
==> amazon-ebs: starting sftp subsystem
    amazon-ebs: changed: [default]
    amazon-ebs:
    amazon-ebs: RUNNING HANDLER [restart docker daemon] ****************************************
==> amazon-ebs: starting sftp subsystem
    amazon-ebs: changed: [default]
    amazon-ebs:
    amazon-ebs: PLAY RECAP *********************************************************************
    amazon-ebs: default                    : ok=13   changed=9    unreachable=0    failed=0
    amazon-ebs:
==> amazon-ebs: shutting down the SSH proxy
==> amazon-ebs: Stopping the source instance...
==> amazon-ebs: Waiting for the instance to stop...
==> amazon-ebs: Creating the AMI: packer-example 1463885332
    amazon-ebs: AMI: ami-39ec7a4a
==> amazon-ebs: Waiting for AMI to become ready...
==> amazon-ebs: Terminating the source AWS instance...
==> amazon-ebs: Cleaning up any extra volumes...
==> amazon-ebs: Deleting temporary security group...
==> amazon-ebs: Deleting temporary keypair...
Build 'amazon-ebs' finished.

==> Builds finished. The artifacts of successful builds are:
--> amazon-ebs: AMIs were created:

eu-west-1: ami-39ec7a4a
```

## packer config quirks

we need this for centos-based source_ami

     "sftp_command": "/usr/libexec/openssh/sftp-server -e"

will try to reach private ip without this

     "associate_public_ip_address": "true"

couldn't run an on-demand instance, had to use spot instance for creating an ami:

     "Error launching source instance: InstanceLimitExceeded: You have requested more instances (1) than your current instance limit of 0 allows for the specified instance type."

## todos

TODO: terminate the instance just before the hour ends just to save some cents --- http://shlomoswidler.com/2011/02/play-chicken-with-spot-instances.html 

TODO: try replace_all_instances --- https://t37.net/why-ansible-1-8-is-the-new-immutable-deployment-killer.html

maybe later try this:
https://pypi.python.org/pypi/ansible-ec2-inventory
https://github.com/paperhive/ansible-ec2-inventory

TODO: upgrade to latest debian
