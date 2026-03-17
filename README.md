# Kubernetes Authentication Automation (Akeyless)

This repository contains scripts to automate the trust establishment between a Kubernetes cluster and Akeyless Gateway.

## 📂 Core Components
| File | Function |
| :--- | :--- |
| k8s_auth_creation.sh | **Setup**: Creates K8s namespace, ServiceAccount, and configures Akeyless Auth Method + Gateway Config. |
| clean_up.sh | **Cleanup**: Removes all K8s and Akeyless resources created by the setup script. |

## ⚙️ Configuration Variables
The following template variables are defined within the scripts:

### Kubernetes Settings
- **TEST_NS**: `your-namespace` (Target namespace)
- **SA_NAME**: `your-service-account-name` (ServiceAccount for token reviews)
- **SA_FILE/TOKEN_FILE**: Manifests for SA and Secret creation

### Akeyless Settings
- **AUTH_METHOD_NAME**: `/your-path/your-auth-method`
- **GW_CONFIG_NAME**: `your-gw-config-name`
- **GW_URL**: `https://your-akeyless-gateway-url/api/v1`

## 🚀 Usage
1. Export your gateway URL:
```bash
export AKEYLESS_GATEWAY_URL="https://your-akeyless-gateway-url/api/v1"
```
2. Run `./k8s_auth_creation.sh` to setup or `./clean_up.sh` to remove resources.

---
**Maintained by**: [Template Repository]
