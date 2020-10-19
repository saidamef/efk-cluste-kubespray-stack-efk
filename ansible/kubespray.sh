git -C ${CI_PROJECT_DIR}/ansible/ clone https://github.com/kubernetes-sigs/kubespray.git 
git -C ${CI_PROJECT_DIR}/ansible/kubespray  checkout v2.13.2 

### RETRIVE IPS FROM GOOGLE API

echo -E ${GOOGLE_CREDENTIALS} > /tmp/academy_cluster_sa.json
declare -a IPS=(${NODES_IP})

##IF USING BASTION MACHINE  
export NODES_INTERNAL_IPS=$(${INTERNAL_IP})
export BASTION_PUBLIC_IP=$(${BASTION_IP})
declare -a IPS=(echo "${NODES_INTERNAL_IPS} ${BASTION_PUBLIC_IP}") && echo "${IPS}"

###USE INVENTORY BUILDER TO CREATE INVENTORY  

export CONFIG_FILE="${CI_PROJECT_DIR}/ansible/kubespray/inventory/mycluster/hosts.yaml"
pip3 install -r "${CI_PROJECT_DIR}"/ansible/kubespray/requirements.txt
cp -rfp "${CI_PROJECT_DIR}"/ansible/kubespray/inventory/sample "${CI_PROJECT_DIR}"/ansible/kubespray/inventory/mycluster
python3 "${CI_PROJECT_DIR}"/ansible/kubespray/contrib/inventory_builder/inventory.py $IPS[@]
cat "${CI_PROJECT_DIR}"/ansible/kubespray/inventory/mycluster/hosts.yaml

##IF USING BASTION
sed -i 's/bastion_ip/'${BASTION_PUBLIC_IP}'/g'  "${CI_PROJECT_DIR}"/ansible/bastion_inventory.yaml
sed -i 's/bastion_user/'root'/g'  "${CI_PROJECT_DIR}"/ansible/bastion_inventory.yaml
cat "${CI_PROJECT_DIR}"/ansible/bastion_inventory.yaml
#MERGE BASTION INVENTORY IN HOSTS INVENTORY

cd "${CI_PROJECT_DIR}"/ansible
sed -i -e'/children:/ { r bastion_inventory.yaml' -e '; :L; n; bL;}'  "${CI_PROJECT_DIR}"/ansible/kubespray/inventory/mycluster/hosts.yaml
cat "${CI_PROJECT_DIR}"/ansible/kubespray/inventory/mycluster/hosts.yaml

###SPIN UP CLUSTER

mkdir ~/.ssh 
echo  "${TF_VAR_BASTION_PRIV_KEY=}" | tr -d '\r' > ~/.ssh/admin && echo  "${TF_VAR_BASTION_PUB_KEY=}" > ~/.ssh/admin.pub
chmod -R 0400 ~/.ssh && eval $(ssh-agent -s) && ssh-add ~/.ssh/admin
cd "${CI_PROJECT_DIR}"/ansible/kubespray && export ANSIBLE_TIMEOUT=100
ansible-playbook -i "${CI_PROJECT_DIR}"/ansible/kubespray/inventory/mycluster/hosts.yaml --become --become-user=root --user=root "${CI_PROJECT_DIR}"/ansible/kubespray/cluster.yml
