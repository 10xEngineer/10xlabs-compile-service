# 10xLabs compile service infrastructure

Consists of:
* compiler stub deployed on each individual compiler node
* individual build packs
* DEB package provisioning scripts

Usage:

	/opt/10xlabs-compile/bin/create kit_name rsa_key

	/opt/10xlabs-compile/bin/exec SANDBOX-ID

	/opt/10xlabs-compile/bin/destroy SANDBOX-ID 


## Compile Kit structure

* **TODO** bin/version should test all dependencies before returning actual version