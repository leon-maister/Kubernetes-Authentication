# Kubernetes Authentication Automation (Akeyless)

This repository contains scripts to automate the trust establishment between a Kubernetes cluster and Akeyless Gateway.

## 📂 Core Components
| File | Function |
| :--- | :--- |
| k8s_auth_creation.sh | **Setup**: Creates K8s namespace, ServiceAccount, and configures Akeyless Auth Method + Gateway Config. |
| clean_up.sh | **Cleanup**: Removes all K8s and Akeyless resources created by the setup script. |

## ⚙️ Configuration Variables
The following variables are defined within the scripts for consistency:

### Kubernetes Settings
- **TEST_NS**: `leon-k8-auth-test` (Target namespace)
- **SA_NAME**: `gateway-token-reviewer` (ServiceAccount for token reviews)
- **SA_FILE/TOKEN_FILE**: Manifests for SA and Secret creation

### Akeyless Settings
- **AUTH_METHOD_NAME**: `/K8s/k8s-auth-leon-test`
- **GW_CONFIG_NAME**: `k8s-config-created-by-script`
- **GW_URL**: `https://gw-gke.lm.cs.akeyless.fans/api/v1`

## 🚀 Usage
1. Export the gateway URL:
```bash
export AKEYLESS_GATEWAY_URL="https://gw-gke.lm.cs.akeyless.fans/api/v1"
```
2. Run `./k8s_auth_creation.sh` to setup or `./clean_up.sh` to remove resources.

---
**Maintained by**: [leon-maister](https://github.com/leon-maister)
