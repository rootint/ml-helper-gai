add-apt-repository -y ppa:deadsnakes/ppa

apt-get update
apt-cache search python3.11

apt-get install python3.11 -y

curl -sSL https://bootstrap.pypa.io/get-pip.py -o get-pip.py
python3.11 get-pip.py