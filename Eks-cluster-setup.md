```
Kubectl--> 
----------
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl
mv kubectl /usr/local/bin/kubectl
```
```
eksctl -->
-------
curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
sudo mv /tmp/eksctl /usr/local/bin
eksctl version

eksctl create cluster \
  --name sk-cluster \
  --region eu-west-1 \
  --node-type c7i-flex.large \
  --node-volume-size 25
```
```
export CLUSTER_NAME= sk-cluster
export AWS_REGION=eu-west-1

TO Delete
---------
eksctl delete cluster \
  --name sk-cluster \
  --region eu-west-1
```

```
Craete SA & Attaching Role using Pod Identity Provider Agent
-----------------------------------------------------------
1. Install the EKS Pod Identity Agent
eksctl create addon \
  --cluster "$CLUSTER_NAME" \
  --region "$AWS_REGION" \
  --name eks-pod-identity-agent

kubectl get pods -n kube-system | grep pod-identity

----------------------------------------------
2. Create the ServiceAccount, IAM role, and association together
eksctl create podidentityassociation \
  --cluster "$CLUSTER_NAME" \
  --region "$AWS_REGION" \
  --namespace kube-system \
  --service-account-name efs-csi-controller-sa \
  --role-name "AmazonEKS_EFS_CSI_DriverRole" \
  --permission-policy-arns arn:aws:iam::aws:policy/service-role/AmazonEFSCSIDriverPolicy \
  --create-service-account
```

```
FOR IAM OIDC provider 
---------------------
1.Set your cluster details \

  export CLUSTER_NAME=sk-cluster \
  export AWS_REGION=eu-west-1

2.Check your AWS identity and cluster:
aws sts get-caller-identity 
aws eks describe-cluster \
  --name "$CLUSTER_NAME" \
  --region "$AWS_REGION" \
  --query 'cluster.status' \
  --output text

3. Associate the IAM OIDC provider
  eksctl utils associate-iam-oidc-provider \
  --cluster "$CLUSTER_NAME" \
  --region "$AWS_REGION" \
  --approve
```
```
4. Create the EFS CSI IAM role 
   export ROLE_NAME=AmazonEKS_EFS_CSI_DriverRole
  eksctl create iamserviceaccount \
  --cluster "$CLUSTER_NAME" \
  --region "$AWS_REGION" \
  --namespace kube-system \
  --name efs-csi-controller-sa \
  --role-name "$ROLE_NAME" \
  --attach-policy-arn arn:aws:iam::aws:policy/service-role/AmazonEFSCSIDriverPolicy \
  --approve

5. Install the EFS CSI driver >> Ypu can also use Helm but you need to attach IAM rile explicitly
  eksctl create addon \
  --cluster "$CLUSTER_NAME" \
  --region "$AWS_REGION" \
  --name aws-efs-csi-driver \2
  --service-account-role-arn "$(aws iam get-role --role-name AmazonEKS_EFS_CSI_DriverRole --query 'Role.Arn' --output text)"
```
```
Create the EBS CSI IAM role
eksctl create iamserviceaccount \
  --cluster "$CLUSTER_NAME" \
  --region "$AWS_REGION" \
  --namespace kube-system \
  --name ebs-csi-controller-sa \
  --role-name AmazonEKS_EBS_CSI_DriverRole \
  --attach-policy-arn arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy \
  --approve

FOR EBS CSI Driver
----------------
aws eks create-addon \
  --cluster-name "$CLUSTER_NAME" \
  --region "$AWS_REGION" \
  --addon-name aws-ebs-csi-driver \
  --service-account-role-arn "$(aws iam get-role --role-name AmazonEKS_EBS_CSI_DriverRole --query 'Role.Arn' --output text)" \
  --resolve-conflicts OVERWRITE
```
```
CHECK
------
aws eks list-addons \
  --cluster-name "$CLUSTER_NAME" \
  --region "$AWS_REGION"

aws eks describe-addon \
  --cluster-name "$CLUSTER_NAME" \
  --region "$AWS_REGION" \
  --addon-name aws-ebs-csi-driver \
  --query 'addon.{Status:status,Health:health.issues}' 
```
```
Install Helm
-----------
 curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
 chmod 700 get_helm.sh
./get_helm.sh
```
```
EBS CSI Driver
--------------
First, create the EBS IAM role and service account as discussed earlier. Then install the chart:
----------------------------------------------------------------------------------------
helm repo add aws-ebs-csi-driver \
  https://kubernetes-sigs.github.io/aws-ebs-csi-driver

helm repo update

helm upgrade --install aws-ebs-csi-driver \
  aws-ebs-csi-driver/aws-ebs-csi-driver \
  --namespace kube-system
```
```
EFS CSI Driver
--------------
Create the EFS IAM role and service account first, then install:
--------------------------------------------------------------
helm repo add aws-efs-csi-driver \
  https://kubernetes-sigs.github.io/aws-efs-csi-driver/

helm repo update

helm upgrade --install aws-efs-csi-driver \
  aws-efs-csi-driver/aws-efs-csi-driver \
  --namespace kube-system
```
```
Install NGINX Ingress Controller...."This controller uses the nginx IngressClass name"
---------------------------------

helm repo add nginx-stable https://helm.nginx.com/stable
helm repo update

helm upgrade --install nginx-ingress nginx-stable/nginx-ingress \
  --namespace nginx-ingress \
  --create-namespace

kubectl get pods -n nginx-ingress
kubectl get svc -n nginx-ingress
kubectl get ingressclass
```

```
Install cert-manager using its official Helm chart
-----------------------------------------------

helm install cert-manager \
  oci://quay.io/jetstack/charts/cert-manager \
  --version v1.20.4 \
  --namespace cert-manager \
  --create-namespace \
  --set crds.enabled=true

Verify:
-----
kubectl get pods -n cert-manager
kubectl get crds | grep cert-manager

```
```
