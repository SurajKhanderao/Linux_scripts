Launch Amazon Linux 2023 , t2.micro

Attach a IAM ROLE TE=EC2, Permisions = admin

vi .bashrc

export PATH=$PATH:/usr/local/bin/
:wq!

source .bashrc

ssh-keygen

cp /root/.ssh/id_rsa.pub my-keypair.pub

chmod 777 my-keypair.pub

vi kops.sh

curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
wget https://github.com/kubernetes/kops/releases/download/v1.32.0/kops-linux-amd64

chmod +x kops-linux-amd64 kubectl

mv kubectl /usr/local/bin/kubectl
mv kops-linux-amd64 /usr/local/bin/kops

aws s3api create-bucket --bucket suraj-kops-testbkt143333.k8s.local --region eu-west-1 --create-bucket-configuration LocationConstraint=eu-west-1
aws s3api put-bucket-versioning --bucket suraj-kops-testbkt143333.k8s.local --region eu-west-1 --versioning-configuration Status=Enabled
export KOPS_STATE_STORE=s3://suraj-kops-testbkt143333.k8s.local

kops create cluster \
  --name=suraj.k8s.local \
  --zones=eu-west-1a,eu-west-1b \
  --control-plane-count=1 \
  --control-plane-size=c7i-flex.large \
  --node-count=2 \
  --node-size=c7i-flex.large \
  --node-volume-size=20 \
  --control-plane-volume-size=20 \
  --ssh-public-key=my-keypair.pub \
  --image=ami-06468be052a4195a6 \
  --networking=calico \
  --topology=public
  kops update cluster --name suraj.k8s.local --yes --admin


wq!

sh kops.sh

export KOPS_STATE_STORE=s3://suraj-kops-testbkt143333.k8s.local

kops validate cluster --wait 10m


-- kops get cluster

-- kubectl get nodes/no

-- kubectl get nodes -o wide

Suggestions:
 * list clusters with: kops get cluster
 * edit this cluster with: kops edit cluster suraj.k8s.local
 * edit your node instance group: kops edit ig --name=suraj.k8s.local nodes-ap-south-1a
 * edit your control-plane instance group: kops edit ig --name=suraj.k8s.local control-plane-ap-south-1a


kops delete cluster --name suraj.k8s.local --yes



