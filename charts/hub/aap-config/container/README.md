# Validated Pattern Imperative Container

[![Quay Repository](https://img.shields.io/badge/Quay.io-imperative--container-blue?logo=quay)](https://quay.io/repository/hybridcloudpatterns/imperative-container)

An imperative container for simplified execution of imperative commands in each of the Validated Patterns.

## Overview

This container provides a focused environment with essential tools for executing imperative commands and automation tasks in Validated Patterns. It includes Ansible, Kubernetes tools, and other utilities needed for pattern implementation and management.


## Installed Software

|          name    |  type    |version|
|:----------------:|:--------:|:-----:|
|ansible           |pip       |2.16.14|
|ansible.posix     |collection|2.1.0  |
|ansible-runner    |pip       |2.4.1  |
|ansible.utils     |collection|6.0.0  |
|community.general |collection|11.2.1 |
|community.okd     |collection|5.0.0  |
|git-core          |package   |2.47.3 |
|gzip              |package   |1.12   |
|jmespath          |pip       |1.0.1  |
|jq                |package   |1.6    |
|kubernetes.core   |collection|6.1.0  |
|kubernetes        |pip       |33.1.0 |
|make              |package   |4.3    |
|openshift         |binary    |4.16.14|
|python3-pip       |package   |21.3.1 |
|python            |package   |3.11.11|
|rhvp.cluster_utils|collection|1.1.0  |
|sshpass           |package   |1.09   |

## Usage

### Pull the Image

```bash
podman pull quay.io/hybridcloudpatterns/imperative-container:latest
```

### Examples

**Interactive shell**

```bash
podman run --rm -it --net=host \
  --security-opt label=disable \
  -v ${HOME}:/pattern \
  -v ${HOME}:${HOME} \
  -w $(pwd) \
  quay.io/hybridcloudpatterns/imperative-container:latest sh
```

**Execute an Ansible playbook**

```bash
podman run --rm -it --net=host \
  --security-opt label=disable \
  -v ${HOME}:/pattern \
  -v ${HOME}:${HOME} \
  -w $(pwd) \
  quay.io/hybridcloudpatterns/imperative-container:latest \
  ansible-playbook <playbook>.yml
```

## Troubleshooting

**Permission issues with volume mounts**
- Ensure the `--security-opt label=disable` flag is used when running the container.
- Check that your user has read/write access to the mounted directories.

**Network connectivity issues**
- Use `--net=host` for full network access.
- For restricted environments, configure appropriate network policies.

**Missing tools or outdated versions**
- Check the installed software table above for current versions.
- Consider building a custom image if you need different tool versions.

## Development

### Build the Image

Run `make build` to build both amd64 and arm64 architectures locally (requires qemu-user-static package).

### Upload to Registry

Run `make upload` to push the image to the official repository.

### Contributing

To update software versions or add new tools, modify the Containerfile and update the software table in this readme. Use `make versions` to generate the software versions table from the container after building locally.
