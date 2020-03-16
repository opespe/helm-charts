# accessnode

The OPES Access Node (AN) is a service that receives partials tallies from PNs on their mobile app, adds the AN's half of the tally to the request, and then submits the full tally to the OPES Batch service for submission to the OPES chain.

## Introduction

This chart installs an OPES Access Node deployment on a [Kubernetes](http://kubernetes.io) cluster using the [Helm](https://helm.sh) package manager.

## Prerequisites

* Kubernetes 1.13+ (Will probably work on some older versions.)

## Installing the Chart

To install the chart with the release name `my-an`, an OPES AN account name of `antstr111111`, a display name of `AN Tester`, and your OPES AN account's private key in JWK format:

```
$ helm install charts/accessnode --name my-an --set name=antstr111111 --set displayName='AN Tester' --set jwk='{"kty":"EC","crv":"P-256K","kid":"antstr111111","x":"Pdocl4EQap70ZXYpikmbmdiaauoiUkbD492iudSuY/c=","y":"N0Dhf2p720m3KQMlup+5beV116ibJCKwMvS3UOQlI4E=","d":"SnpJcxLdDhUVGr+CRBbcQ1Zn0MqtO3oMPPX+rTrD7lc="}'
```

> NOTE: See `examples/ingress-example-values.yaml` for a full example that also exposes the service via a Kubernetes ingress object.

### Verifying Installation

After your access node service is deployed you can run the following `curl` command to verify that it is working and correctly.

```
curl -H 'x-api-version: 1.0' https://<accessnode hostname>/qr/payload
```

The above command should return a deep link URL that can be used for creating 'Support Us' links and QR codes. The link returned will be similar to the below example:

```
https://mobile.opes.pe/opesapp/check-in?ref=qrcode&name=My+AN&url=https%3A%2F%2Fmy-an.example.org
```

## Uninstalling the Chart

To uninstall/delete the `my-an` deployment:

```
$ helm delete --purge my-an
```

The command removes all the Kubernetes components associated with the chart and deletes the release.

## Configuration

The following table lists the configurable parameters of the accessnode chart and their default values.

| Parameter     | Description   | Default
| ------------- | ------------- | ----------
| image.repository | The Docker image to deploy | `opespe/accessnode`
| image.tag | The Docker tag to deploy | `0.3.0`
| image.pullPolicy  | The image pull policy | `IfNotPresent`
| nameOverride  | Override the resource name prefix | Not Set
| fullnameOverride  | Override the full resource names  | Not Set
| service.type  | The K8S service type  | `ClusterIP`
| service.port  | The K8S service port  | `8080`
| ingress.enabled   | Enables Ingress   | `false`
| ingress.annotations   | Ingress annotations   | `{}`
| ingress.hosts | Ingress hosts configuration | `[]`
| ingress.tls   | Ingress TLS configuration | `[]`
| resources | Resources allocation (Requests and Limits)    | `{}`
| nodeSelector  | Node labels for pod assignment    | `{}`
| tolerations   | Toleration labels for pod assignment  | `[]`
| affinity  | Affinity settings | `{}`
| name  | OPES Chain Access Node Account Name   | `myan11111111`
| displayName   | Access Node's Display Name    | `My Access Node`
| jwk   | The Access Node's OPES chain private key in JWK format    | `{"kty":"EC","crv":"P-256K","kid":"myan11111111","x":"Pdocl4EQap70ZXYpikmbmdiaauoiUkbD492iudSuY/c=","y":"N0Dhf2p720m3KQMlup+5beV116ibJCKwMvS3UOQlI4E=","d":"SnpJcxLdDhUVGr+CRBbcQ1Zn0MqtO3oMPPX+rTrD7lc="}`
| micronautEnvironments | The active Micronaut Environments | `prod`
| deepLinkHostUrl   | The URL to the OPES deep link site    | `https://mobile.opes.pe`
| batchService.url  | The URL for the OPES Batch Service | `https://batch.opesx.io`
| batchService.retryDelay   | The delay between retries for sending a tally | `5s`
| batchService.retryAttempts    | The number of attempts for sending a tally    | `2`
| batchService.apiVersion   | The OPES Batch Service API Version    | `1.0`
| batchService.opesServiceKeys   | The OPES Service Keys   | `https://opes-opesservice.opesx.io/keys`

Specify each parameter using the `--set key=value[,key=value]` argument to `helm install`.

Alternatively, a YAML file that specifies the values for the above parameters can be provided while installing the chart. For example,

```bash
$ helm install charts/accessnode --name my-an -f values.yaml
```

> **TIP:** To get the JWK format of your AN's OPES private key, you can run `docker run --rm opespe/opes-key-tools --command=key_To_JWK --kid=<accessnode account name> --key=<private key value>`
