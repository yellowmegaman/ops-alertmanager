# ops-alertmanager

Allows you to deploy alertmanager via Nomad

Expects "DC" env variable.

Example:

```
levant deploy -address=http://your-nomad-installation-or-cluster:4646 -var-file=vars.yaml ops-alertmanager.nomad
```
