
#!/bin/bash
yum -y update
yum -y install python3 python3-pip python3-venv
yum install -y libselinux-python3
python3 -m venv /usr/local/ilke-env
source /usr/local/ilke-env/bin/activate
pip3 install --upgrade pip
pip3 install -r requirements.txt
ansible --version

