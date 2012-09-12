# 10xLabs compile service infrastructure

First version of a compiler-as-a-service infrastructure for 10xLabs. 

Consists of:
* compile wrapper which gets deployed on each individual compiler node
* individual build packs
* Debian/Ubuntu package build scripts

## Compile Kit cookbook

It's easy to create new compile kit. Directory structure is following

* `bin` with the all actions supported by compile kit (exposed via comp_serv API)
* `etc` internal configuration (`etc/version` is used for versioning - both internal and deb package)
* `sbin` for `sbin/setup` script which is used to install compile kit dependencies

Compile kit name should include only `a..z0..9-`, ie. `10xeng-java` and not (10xeng_java).

## Compile Kit Actions

All compile kit actions are executed with the UID of sandbox owner (same as sandbox name) and within the sandbox directory.

Action output gets streamed back to the user as-it-is. 

# TODOs

* set default nice/cgroups for all executed actions
* limit execution of action to 10 seconds / 30 seconds (based on the tenant)
* sandbox quota