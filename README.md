# First Encounter of Karpenter Setup/Installation in AWS EKS Cluster

## Step 1 :
Create AWS S3 Bucket for .tfstate file

## Step 2 :
Follow the Point 9 in this URL https://www.cloudnativedeepdive.com/implementing-karpenter-in-eks-from-start-to-finish/ , under "Create the EKS Cluster", to create EKS cluster.

## Step 3 :
Follow the Point 9 in this URL https://www.cloudnativedeepdive.com/implementing-karpenter-in-eks-from-start-to-finish/ , under "Create the EKS Cluster", to perform terraform init, terraform plan, and terraform apply --auto-approve.

## Step 4
Follow the section "Configure OIDC For Your Cluster" in this URL https://www.cloudnativedeepdive.com/implementing-karpenter-in-eks-from-start-to-finish/ , to configure OIDC for the cluster.

## Step 5
Integrate Point 1 & 2 of the section "Configuring An IAM Role For Karpenter To Access EC2", with the main.tf and varaiables.tf files.

## Step 6
Follow Point 3 of the section "Configuring An IAM Role For Karpenter To Access EC2", create the role via Terraform and confirm that it is working, using the command "aws iam get-role --role-name karpenter-role --query Role.AssumeRolePolicyDocument". Also verify the output along in this Point 3.

## Step 7
Install Karpenter following the section "Installing Karpenter Via Helm".

helm registry logout public.ecr.aws

helm upgrade --install karpenter oci://public.ecr.aws/karpenter/karpenter --namespace karpenter --create-namespace \
        --set "settings.clusterName=${EKS_CLUSTER_NAME}" \
        --set "settings.interruptionQueue=${EKS_CLUSTER_NAME}" \
        --set controller.resources.requests.cpu=1 \
        --set controller.resources.requests.memory=1Gi \
        --set controller.resources.limits.cpu=1 \
        --set controller.resources.limits.memory=1Gi \
        --wait

Note : You may remove the "--wait" option, if you persistly getting error like, "Error: context deadline exceeded".

## Step 8
Need not follow the "Configuring Scalability Options" section, but to use the nodepool.yaml file in this repo.

## Step 10
Simulate the deployment inflation using the following commands.

kubectl create deployment inflate --image=public.ecr.aws/eks-distro/kubernetes/pause:3.2 --replicas=0
kubectl scale deployment inflate --replicas=5
kubectl scale deployment inflate --replicas=10

kubectl get nodes -w

In another terminal (Watch nodes being added in real-time:) :
kubectl get pods -o wide

Check Karpenter logs to see provisioning activity:
kubectl logs -n karpenter -l app.kubernetes.io/name=karpenter -f


## Step 11
**Install Prometheus and Grafana using Helm:**
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update

helm install prometheus prometheus-community/kube-prometheus-stack --namespace monitoring --create-namespace

## Step 12 :
**Get Grafana 'admin' user password by running:**

  kubectl --namespace monitoring get secrets prometheus-grafana -o jsonpath="{.data.admin-password}" | base64 -d ; echo

Access Grafana local instance:

  export POD_NAME=$(kubectl --namespace monitoring get pod -l "app.kubernetes.io/name=grafana,app.kubernetes.io/instance=prometheus" -oname)
  kubectl --namespace monitoring port-forward $POD_NAME 3000

Visit https://github.com/prometheus-operator/kube-prometheus for instructions on how to create & configure Alertmanager and Prometheus instances using the Operator.

## Step 13 :
**Get Grafana admin password:**
  kubectl get secret --namespace monitoring prometheus-grafana -o jsonpath="{.data.admin-password}" | base64 --decode

Port-forward to access Grafana:
 kubectl port-forward --namespace monitoring svc/prometheus-grafana 3000:80

 ## Step 14
 **Access Grafana at http://localhost:3000 (username: admin, password from step 12)**

## Step 15
**Import Karpenter dashboard:**

Go to Dashboards → Import

Use dashboard ID: 17900 (official Karpenter dashboard)

Select Prometheus as data source

## Step 16
**Verify Karpenter metrics are being scraped:**
  kubectl get servicemonitor -n monitoring | grep karpenter
