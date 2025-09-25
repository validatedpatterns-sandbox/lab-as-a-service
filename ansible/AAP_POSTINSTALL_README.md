# AAP Post-Installation Playbooks

This directory contains a collection of Ansible playbooks for post-installation configuration of Ansible Automation Platform (AAP) on OpenShift. These playbooks handle license management, token creation, and comprehensive AAP configuration.

## Overview

The AAP post-installation process consists of several stages:

1. **License Management** - Apply AAP license/manifest
2. **Token Creation** - Create admin tokens for automation
3. **Configuration** - Set up AAP resources (projects, inventories, job templates, etc.)

## Prerequisites

### Required Collections
Install the required Ansible collections:
```bash
ansible-galaxy collection install -r common/requirements.yml
```

### Required Collections Include:
- `ansible.controller` - For AAP 2.5+ license and resource management
- `awx.awx` - For legacy AAP/AWX compatibility
- `kubernetes.core` - For OpenShift/Kubernetes operations
- `infra.aap_configuration` - For AAP configuration management

### OpenShift Access
Ensure you have access to the OpenShift cluster where AAP is installed:
```bash
# Option 1: Login with oc CLI
oc login -u <username> -p <password> <cluster-url>

# Option 2: Set KUBECONFIG environment variable
export K8S_AUTH_KUBECONFIG=/path/to/kubeconfig
```

### AAP Installation
- AAP must be installed and running on OpenShift
- AAP routes must be accessible
- Admin credentials must be available

## Playbooks

### 1. `aap_postinstall_license.yaml`
**Purpose**: Apply AAP license using a local manifest file

**Features**:
- Uses `infra.aap_configuration.controller_license` role
- Supports local manifest file path
- Automatic AAP discovery and credential retrieval

**Usage**:
```bash
ansible-playbook aap_postinstall_license.yaml
```

**Variables**:
- `aap_namespace`: OpenShift namespace where AAP is installed (default: "aap")
- `aap_app_name`: AAP application name (default: "example-aap")

---

### 2. `aap_postinstall_license_from_ocp.yml`
**Purpose**: Apply AAP license from an OpenShift secret containing the manifest

**Features**:
- Retrieves manifest from OpenShift secret named `aap-manifest`
- Supports both modern (`ansible.controller.license`) and legacy (`awx.awx.license`) modules
- Automatic fallback for compatibility
- Comprehensive error handling and retries

**Usage**:
```bash
# First, create the manifest secret
kubectl create secret generic aap-manifest --from-file=manifest=/path/to/manifest.zip -n aap

# Then run the playbook
ansible-playbook aap_postinstall_license_from_ocp.yml
```

**Secret Requirements**:
- Secret name: `aap-manifest`
- Key: `manifest` (containing the license manifest content)
- Namespace: Same as AAP installation

---

### 3. `aap_postinstall_create_admin_token.yml`
**Purpose**: Create an AAP admin token with write permissions and store it in OpenShift

**Features**:
- Creates controller OAuth token (not generic AAP admin token)
- Stores token in OpenShift secret `aap-config-access`
- Includes all necessary connection details in the secret
- Provides usage instructions

**Usage**:
```bash
ansible-playbook aap_postinstall_create_admin_token.yml
```

**Created Secret Structure**:
```yaml
apiVersion: v1
kind: Secret
metadata:
  name: aap-config-access
  namespace: aap
data:
  token: <base64-encoded-token>
  hostname: <base64-encoded-hostname>
  username: <base64-encoded-username>
  validate_certs: <base64-encoded-boolean>
```

---

### 4. `aap_postinstall_config.yaml`
**Purpose**: Configure AAP resources using username/password authentication

**Features**:
- Uses `infra.aap_configuration.dispatch` role
- Loads configuration from `aap_postinstall/` directory
- Supports all AAP resource types (projects, inventories, job templates, etc.)
- Password-based authentication

**Usage**:
```bash
ansible-playbook aap_postinstall_config.yaml
```

**Configuration Directory**: `./aap_postinstall/`

---

### 5. `aap_postinstall_config_with_token.yaml`
**Purpose**: Configure AAP resources using token-based authentication

**Features**:
- Uses token from `aap-config-access` secret
- More secure than password-based authentication
- Requires prior execution of `aap_postinstall_create_admin_token.yml`
- Same configuration capabilities as password-based version

**Usage**:
```bash
# First create the token
ansible-playbook aap_postinstall_create_admin_token.yml

# Then configure AAP
ansible-playbook aap_postinstall_config_with_token.yaml
```

## Configuration Directory: `aap_postinstall/`

This directory contains YAML files defining AAP resources:

### Available Configuration Files:
- `controller_organizations.yml` - Organizations
- `controller_teams.yml` - Teams within organizations
- `controller_credentials.yml` - Credentials for various systems
- `controller_projects.yml` - SCM projects
- `controller_inventories.yml` - Inventories, hosts, and groups
- `controller_job_templates.yml` - Job templates
- `controller_workflow_job_templates.yml` - Workflow job templates

### Configuration Order:
The AAP configuration role processes resources in dependency order:
1. Organizations
2. Teams
3. Credentials
4. Projects
5. Inventories (including hosts and groups)
6. Job Templates
7. Workflow Job Templates

### Example Configuration Structure:
```yaml
# controller_projects.yml
controller_projects:
  - name: "Demo Project"
    description: "Sample project for demonstration"
    organization: "Default"
    scm_type: git
    scm_url: "https://github.com/ansible/ansible-examples.git"
    scm_branch: "master"
    scm_clean: true
    scm_update_on_launch: true
```

## Helper Files

### `aap_get_credentials.yml`
**Purpose**: Discover AAP routes and retrieve admin credentials from OpenShift

**Features**:
- Automatically finds AAP routes using labels
- Retrieves admin password from OpenShift secrets
- Sets facts for use in other playbooks

**Included by**: All AAP post-installation playbooks

### `aap_get_token_from_secret.yml`
**Purpose**: Retrieve AAP admin token from OpenShift secret

**Features**:
- Extracts token and connection details from `aap-config-access` secret
- Sets facts for token-based authentication
- Used by `aap_postinstall_config_with_token.yaml`

## Common Variables

### Global Variables:
- `aap_namespace`: OpenShift namespace (default: "aap")
- `aap_app_name`: AAP application name (default: "example-aap")
- `aap_username`: AAP username (default: "admin")
- `aap_validate_certs`: Certificate validation (default: false)

### Directory Variables:
- `controller_postinstall_dir`: Configuration directory (default: "./aap_postinstall")
- `controller_postinstall_ignore_files`: Files to ignore (default: "./aap_postinstall/ignore_files")

## Execution Workflows

### Complete AAP Setup Workflow:
```bash
# 1. Apply license from OpenShift secret
ansible-playbook aap_postinstall_license_from_ocp.yml

# 2. Create admin token
ansible-playbook aap_postinstall_create_admin_token.yml

# 3. Configure AAP resources
ansible-playbook aap_postinstall_config_with_token.yaml
```

### Alternative License Workflow:
```bash
# 1. Apply license from local file
ansible-playbook aap_postinstall_license.yaml

# 2. Create admin token
ansible-playbook aap_postinstall_create_admin_token.yml

# 3. Configure AAP resources
ansible-playbook aap_postinstall_config_with_token.yaml
```

## Security Considerations

### Token Management:
- Tokens are stored as base64-encoded data in OpenShift secrets
- Use token-based authentication when possible (more secure than passwords)
- Tokens have write scope and should be protected accordingly

### Credential Management:
- Never commit actual credentials to version control
- Use Ansible Vault for sensitive data in configuration files
- Consider using external credential management systems

### Certificate Validation:
- Set `aap_validate_certs: true` in production environments
- Default is `false` for development/testing convenience

## Troubleshooting

### Common Issues:

1. **AAP Route Not Found**:
   - Verify AAP is installed and running
   - Check `aap_app_name` variable matches actual deployment
   - Verify route exists: `oc get routes -n <aap_namespace>`

2. **Secret Not Found**:
   - For license: Ensure `aap-manifest` secret exists
   - For token: Run `aap_postinstall_create_admin_token.yml` first
   - Check namespace: `oc get secrets -n <aap_namespace>`

3. **Authentication Failures**:
   - Verify admin password is correct
   - Check AAP is accessible from the automation host
   - Verify token is valid and has appropriate permissions

4. **Configuration Failures**:
   - Check YAML syntax in configuration files
   - Verify resource dependencies (organizations before teams, etc.)
   - Review AAP logs for detailed error messages

### Debugging:
Add `-v` or `-vv` to ansible-playbook commands for verbose output:
```bash
ansible-playbook -vv aap_postinstall_config_with_token.yaml
```

## Support

For issues specific to these playbooks, check:
1. Ansible collection documentation
2. AAP/AWX documentation
3. OpenShift/Kubernetes documentation
4. Individual playbook comments and TODO items
