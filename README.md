# Helm Charts

This repository contains all of the publicly accessible Helm charts for OPES community to use to assist with standing up their own Access Nodes and Infrastructure Nodes.

## How do I install these charts?

Clone this repository to you computer and then run `helm install charts/<chart>`.

For more information on a particular chart, view the README in the corresponding chart's directory.

For more information on using Helm, refer to the [Helm's documentation](https://github.com/kubernetes/helm#docs).


# Infranode standalone setup on GCP project 
Steps:
* Setup a basic K8 cluster on cloud environment ( for example GCP)
* Install helm2 server and client based by running the following commands  (https://medium.com/google-cloud/installing-helm-in-google-kubernetes-engine-7f07f43c536e)
``` #!/usr/bin/env bash
echo "install helm"
# installs helm with bash commands for easier command line integration
curl https://raw.githubusercontent.com/kubernetes/helm/master/scripts/get | bash
# add a service account within a namespace to segregate tiller
kubectl --namespace kube-system create sa tiller
# create a cluster role binding for tiller
kubectl create clusterrolebinding tiller \
   --clusterrole cluster-admin \
   --serviceaccount=kube-system:tiller

echo "initialize helm"
# initialized helm within the tiller service account
helm init --service-account tiller
# updates the repos for Helm repo integration
helm repo update

echo "verify helm" 
```

* verify that helm is installed in the cluster
kubectl get deploy,svc tiller-deploy -n kube-system
* Infranode helm installation command ( prod keys required for deployment are at https://github.com/opespe/o1.eos-prod-accounts/blob/master/p2p-access-keys/access-key-58.txt

helm install charts/infranode --name my-producer --set producer.name='cn1111111111' --set producer.privkey='5JiB3XXXX' --set auth.enabled='true' --set auth.peerPrivateKey='["EOS5jXXXX"\,"5JiB3XXXX"]'

Note: producer name can be any name that is not deployed before.

Check infranode pod running at cluster
``` kubectl get pods ```

Infranode testing
``` helm test my-producer ```

Checking logs for sync test pod
``` kubectl get logs my-producer-sync-test ```