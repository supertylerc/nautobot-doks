# Deploy DigitalOcean Infrastructure

This repository includes configuration for a minimal Kubernetes cluster
using DigitalOcean's managed Kubernetes service.  This is optional: if
you already have a Kubernetes cluster (such as using
[`minikube`][minikube]), you can skip this step.

First, ensure you have Terraform installed.  The
[official instructions][install-terraform] are succint and cover more
platforms than I could, so go [check them out][install-terraform] if you
don't already have Terraform installed.

You also need to export your DigitalOcean API token as an environment
variable:

```bash
$ export DIGITALOCEAN_TOKEN="example-token-here"
```
> For information on how to generate a token, see the
> [official docs][dotokendocs].

Next, initialize the Terraform project and review the infrastructure
plan:

```bash
$ cd terraform
$ terraform init
$ terraform plan
```

If the plan looks good to you, then start the process of creating the
infrastructure:

```bash
$ terraform apply -auto-approve
```

This process can take up to 10-15 minutes.  It will create (by default)
a VPC and single-node managed Kubernetes cluster in the `tor1` region.
It will also create a firewall and make your cluster a default deny for
inbound and outbound traffic (other than what the managed service itself
opens, which you cannot override).  Holes are poked for outbound DNS,
HTPS, and HTTPS traffic.  No inbound holes are created; your access to
Nautobot later will be done by using `kubectl` to proxy the traffic.

> If you want to override these settings, you can review the
> [`terraform/variables.tf`][variables.tf] file for which variables to
> override based on your needs.

# Deploy Nautobot

This project sets some values for the upstream Nautobot chart.  In
particular, it:

* Uses custom passwords for Redis and PostgreSQL
* Uses TLS to encrypt communication to/from Redis and PostgreSQL
* Overrides resource requests so that everything can be deployed to the smallest cluster possible

To start, we need to ensure our credentials for PostgreSQL and Redis
exist as Secrets:

> If you're still in the `terraform/` directory, make sure you `cd ../`
> before running the commands below.

```bash
$ kubectl create secret \
  generic \
  nautobot-postgres-password \
  --from-literal=postgresql-postgres-password=examplesecret123 \
  --from-literal=postgresql-password=examplesecret123
secret/nautobot-postgresql-password created
$ kubectl create secret \
  generic \
  nautobot-redis-password \
  --from-literal=NAUTOBOT_REDIS_PASSWORD=examplesecret456
secret/nautobot-redis-password created
```

> The above differs slightly from the README in the upstream chart repo.
> This is because I prefer separate secrets for separate purposes and I
> found that the Deployment for Nautobot is looking for two different
> keys in the PostgreSQL secret (whereas the official README only has
> one being created).

Once the secrets exist, we can deploy our chart:

```bash
$ helm repo add nautobot https://nautobot.github.io/helm-charts/
"nautobot" has been added to your repositories
$ helm install nautobot nautobot/nautobot \
  -f ./nautobot-chart-values.yaml \
  --set-file nautobot.config=./nautobot-config.py
NAME: nautobot
LAST DEPLOYED: Fri Jan 28 13:41:45 2022
NAMESPACE: default
STATUS: deployed
REVISION: 1
NOTES:
<SNIP>
```

Once this is done, wait a few minutes (up to 10 in my experiences so
far).  You can monitor the progress using the normal `kubectl` commands,
such as `kubectl get pods` or `kubectl logs $podName`.

# Access Nautobot

Once all pods are running, you can access Nautobot by using the
`kubectl port-forward` command:

```bash
$ kubectl port-forward svc/nautobot 8080:80
Forwarding from 127.0.0.1:8080 -> 8080
Forwarding from [::1]:8080 -> 8080
```

Now just open your preferred browser and navigate to
`http://127.0.0.1:8080`, where you'll be greeted by the default Nautobot
page.  You can login by clicking the button in the top-right corner and
using the credentials below:

```
Username: admin
Password: $(kubectl get secret --namespace default nautobot-env -o jsonpath="{.data.NAUTOBOT_SUPERUSER_PASSWORD}" | base64 --decode)
```

> The above information is also helpfully printed in the output from
> installing the chart, along with some other critical details if you
> decide to run this in production (such as how to take database
> backups).

[minikube]: https://minikube.sigs.k8s.io/docs/
[install-terraform]: https://www.terraform.io/downloads
[dotokendocs]: https://docs.digitalocean.com/reference/api/create-personal-access-token/
[variables.tf]: terraform/variables.tf
