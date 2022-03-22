# infranode

The OPES Infrastructure Node (IN) is a service that provides block production for the OPES chain. It is built on a customized version of [EOSIO](https://eos.io/) block chain technology.

## Introduction

This chart installs an OPES Infrastructure Node deployment on a [Kubernetes](http://kubernetes.io) cluster using the [Helm](https://helm.sh) package manager.

## Prerequisite

* Kubernetes 1.13+ (Will probably work on some older versions.)
* Helm

## Installation

To install the chart with the release name `my-producer`, an OPES IN account name of `cn1111111111`, an IN worker private key of `5KCXicJ8vpagQxNpZzjG2bWsiJHenPfTSq7zzr2GRXjLNDg5swj`, and a network access key of `["EOS6vBx2yzAx7oAGGefeLxhm8LwDLAnrTAxof3xE16ZueWFEemCBy","5JpPqqvcDb8ea9bwkJLeqJceufXx25DgsL9YKGtjodQpsm1BqkG"]` to connect to the public P2P endpoint:

```
$ helm install charts/infranode --name my-producer --set producer.name='cn1111111111' --set producer.privkey='5KCXicJ8vpagQxNpZzjG2bWsiJHenPfTSq7zzr2GRXjLNDg5swj' --set auth.enabled='true' --set auth.peerPrivateKey='["EOS6vBx2yzAx7oAGGefeLxhm8LwDLAnrTAxof3xE16ZueWFEemCBy","5JpPqqvcDb8ea9bwkJLeqJceufXx25DgsL9YKGtjodQpsm1BqkG"]'
```

> NOTE: See `examples/producer-values.yaml` for a full example.

### Verifying Installation

After your infrastructure node service is deployed you can run the following `helm` command, replacing `my-producer` with the release name you used to deploy your IN, to verify that it is working and correctly. 

```
helm test my-producer
```

The above command should run the included test which will start up a pod to verify that the node is syncing blocks from the block chain.

> **NOTE:** If you set the `httpListenAddress` to something other than the default of `0.0.0.0` the test most likely will not succeed. In that scenario, you will want to use the `kubectl logs` command to view the logs of the pod to see if it is syncing block correctly.

## Uninstalling the Chart

To uninstall/delete the `my-producer` deployment:

```
$ helm delete --purge my-producer
```

## Configuration

The following table lists the configurable parameters of the chart and their default values.

Parameter                           | Description                                                               | Default
------------------------------------| ------------------------------------------------------------------------- | -------
image.repository                    | The EOS docker image                                                      | `opespe/infranode`
image.tag                           | The Docker tag to deploy                                                  | `1.1.0`
image.pullPolicy                    | The image pull policy                                                     | `IfNotPresent`
serviceType                         | The Kubernetes service object type                                        | `ClusterIP`
nodeSelector                        | Node selector labels for pod assignment                                   | `{}`
producer.name                       | IN block chain account name (CN account name)                             | `defproducera`
producer.privkey                    | Provide the IN worker private key                                         | `5JVy44L4vmeMdhXbSzfHFzFzEXL4ZLjvkcNfPkWL5Gvo8iQWusN`
extraconfig                         | Additional configuration to pass to Nodeos command line                   | `[]`
peerDiscovery.addresses             | List of other nodes to connect to                                         | `["pub-infra-p2p.opesx.io:9876"]`
auth.enabled                        | Enable authentication in the nodes configuration                          | `false`
auth.type                           | Configures --allowed-connection setting                                   | `any`
auth.peerPrivateKey                 | Configures --peer-private-key setting. Used by node to auth to others     | `Not Set`
auth.peerKeys                       | Configures --peer-key setting. Used to accept incoming connections        | `[]`
backup_recovery.enabled             | Whether to enable starting the chain with block logs from a backup file stored in the image. | false
snapshot_recovery.enabled           | Whether to enable starting the chain with block logs from a snapshot file. | false
snapshot_recovery.fileURI           | The URI for the snapshot image.                                           | Not Set
puzzleService.enabled               | Whether to enable puzzle service plugin                                   | `true`
puzzleService.puzzleServiceUrl      | The web socket URL of the Puzzle service                                  | `wss://puzzler.opesx.io:443`
puzzleService.disableCertValidation | Disables certificate validation for Puzzle service URL                    | `false`
httpListenAddress                   | The address for the HTTP plugin to listen on                              | `0.0.0.0`
maxClients                          | Max P2P clients the relay will allow to connect                           | `25`
maxTransactionTime                  | Nodeos maxTransactionTime setting                                         | `500000`
abiSerializerMaxTimeMs              | Nodeos abiSerializerMaxTimeMs setting                                     | `990000`
genesisJson                         | The content of genesis.json used by all nodes                             | `<See values.yaml> `
persistence.enabled                 | Enable persistent storage                                                 | `true`
persistence.existingClaim           | Specify the name of an existing PVC claim to use                          | `Not Set`
persistence.storageClass            | Specify the storage class to use for the PVC claim                        | `Not Set`
persistence.annotations             | Annonations for the PVC claim                                             | `{}`
persistence.accessMode              | PVC access mode                                                           | `ReadWriteOnce`
persistence.size                    | Size of the PVC                                                           | `20Gi`

Specify each parameter using the `--set key=value[,key=value]` argument to `helm install`.

Alternatively, a YAML file that specifies the values for the above parameters can be provided while installing the chart. For example,

```bash
$ helm install charts/infranode --name my-producer -f values.yaml
```

## Restart from a backup
When it is determined the blockchanin needs to start from a backup a docker container will be created that has the backup 
log aleady as part of it.  Then the startup for helm will need to include flags to set the `image.tag` and `backup_recovery.enabled`
values.  First the existing helm chart should be uninstalled (see [link](#Uninstalling-the-Chart)).  Then use the following 
command to install the chart with the flags set.
```shell script
helm install charts/infranode --name test-producer --set producer.name='testcn111111' --set producer.privkey=5KCXicJ8vpagQxNpZzjG2bWsiJHenPfTSq7zzr2GRXjLNDg5swj --set auth.enabled='true' --set auth.peerPrivateKey='["EOS6aYUdpz1ytYNYmE5YwwffA1aj6dkgJKjhksKY7F5qy4NarMHQX","5HzSLxhwUBA2DtwtmWPZ9DZhZkgebHK1J6wi724vp2Bu5HD9WAH"]' --set backup_recovery.enabled=true --set image.tag='hotfix-07282020-1'
```

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
``` kubectl get deploy,svc tiller-deploy -n kube-system ```
* Infranode helm installation command ( prod keys required for deployment are at https://github.com/opespe/o1.eos-prod-accounts/blob/master/p2p-access-keys/access-key-58.txt

``` helm install charts/infranode --name my-producer --set producer.name='cn1111111111' --set producer.privkey='5JiB3XXXX' --set auth.enabled='true' --set auth.peerPrivateKey='["EOS5jXXXX"\,"5JiB3XXXX"]' ```

Note: producer name can be any name that is not deployed before.

Check infranode pod running at cluster
``` kubectl get pods ```

Infranode testing
``` helm test my-producer ```

Checking logs for sync test pod
``` kubectl get logs my-producer-sync-test ```
