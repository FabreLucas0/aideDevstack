# ça permet de pouvoir utilisé les variable dans le fichier config
source "config.conf"

# dans la premiere partie le script vas configurer le réseau du noeud
touch /etc/sysconfig/network-scripts/ifcfg-eth0
echo "BOOTPROTO=static" > /etc/sysconfig/network-scripts/ifcfg-eth0
echo "IPADDR=$IPADDR" >> /etc/sysconfig/network-scripts/ifcfg-eth0
echo "NETMASK=$NETMASK" >> /etc/sysconfig/network-scripts/ifcfg-eth0
echo "GATEWAY=$GATEWAY" >> /etc/sysconfig/network-scripts/ifcfg-eth0

# le script vas créer l"utilisateur stack
useradd -s /bin/bash -d /opt/stack -m stack
chmod +x /opt/stack
echo "stack ALL=(ALL) NOPASSWD: ALL" | sudo tee /etc/sudoers.d/stack

# le script vas mettre en place la clé ssh
mkdir ~/.ssh; chmod 700 ~/.ssh
ssh-keygen -t rsa -b 4096 -P "$SECURE_PASS_PHRASE" -f "~/.ssh/authorized_keys"
rm -f ~/.ssh/authorized_keys
mv ~/.ssh/authorized_keys.pub ~/.ssh/authorized_keys

# le scrip vas cloné devstack depuis github et se met sur la bonne branche
git clone https://opendev.org/openstack/devstack
cd devstack
git branch stable/2023.1

# le script vas utilisé le compte stack créer plustot
sudo -u stack -i

# si dans le fichier de config on met que le noeud sur lequel on utilise le script est "controller" alors on fais l"installation comme sur le site d"openstack
if [ $NODE == "controller" ]
then
touch local.conf
echo "[[local|localrc]]" > local.conf
echo "HOST_IP=$HOST_IP" >> local.conf
echo "FIXED_RANGE=$FIXED_RANGE" >> local.conf
echo "FLOATING_RANGE=$FLOATING_RANGE=" >> local.conf
echo "LOGFILE=$LOGFILE" >> local.conf
echo "ADMIN_PASSWORD=$ADMIN_PASSWORD" >> local.conf
echo "DATABASE_PASSWORD=$DATABASE_PASSWORD" >> local.conf
echo "RABBIT_PASSWORD=$RABBIT_PASSWORD" >> local.conf
echo "SERVICE_PASSWORD=$SERVICE_PASSWORD" >> local.conf
./stack.sh
fi

# si dans le fichier de config on met que le noeud sur lequel on utilise le script est "compute" alors on fais l"installation comme sur le site d"openstack
if [ $NODE == "compute"]
then
touch local.conf
echo "[[local|localrc]]" > local.conf
echo "HOST_IP=$HOST_IP" >> local.conf
echo "FIXED_RANGE=$FIXED_RANGE" >> local.conf
echo "FLOATING_RANGE=$FLOATING_RANGE=" >> local.conf
echo "LOGFILE=$LOGFILE" >> local.conf
echo "ADMIN_PASSWORD=$ADMIN_PASSWORD" >> local.conf
echo "DATABASE_PASSWORD=$DATABASE_PASSWORD" >> local.conf
echo "RABBIT_PASSWORD=$RABBIT_PASSWORD" >> local.conf
echo "SERVICE_PASSWORD=$SERVICE_PASSWORD" >> local.conf
echo "DATABASE_TYPE=$DATABASE_TYPE" >> local.conf
echo "SERVICE_HOST=$SERVICE_HOST" >> local.conf
echo "MYSQL_HOST=$SMYSQL_HOST" >> local.conf
echo "RABBIT_HOST=$RABBIT_HOST" >> local.conf
echo "GLANCE_HOSTPORT=$GLANCE_HOSTPORT" >> local.conf
echo "ENABLED_SERVICES=$ENABLED_SERVICES" >> local.conf
echo "NOVA_VNC_ENABLED=$NOVA_VNC_ENABLED" >> local.conf
echo "NOVNCPROXY_URL=$NOVNCPROXY_URL" >> local.conf
echo "VNCSERVER_LISTEN=$VNCSERVER_LISTEN" >> local.conf
echo "VNCSERVER_PROXYCLIENT_ADDRESS=$VNCSERVER_PROXYCLIENT_ADDRESS" >> local.conf
./stack.sh
fi