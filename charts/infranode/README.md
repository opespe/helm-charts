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
