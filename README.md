# Kubernetes Authentication Automation (Akeyless)

This repository contains scripts to automate the trust establishment between a Kubernetes cluster and Akeyless Gateway.

## 📂 Core Components
| File | Function |
| :--- | :--- |
| k8s_auth_creation.sh | **Setup**: Creates K8s namespace, ServiceAccount, and configures Akeyless Auth Method + Gateway Config. |
| clean_up.sh | **Cleanup**: Removes all K8s and Akeyless resources created by the setup script. |

## ⚙️ Required Environment Variables
Before running the scripts, you must set the following variable:

```bash
export AKEYLESS_GATEWAY_URL="https://your-gateway-url/api/v1"
```
*Note: The scripts will validate this variable against the internal GW_URL to ensure consistency.*

## 🚀 Usage

### 1. Run Setup
```bash
chmod +x k8s_auth_creation.sh
./k8s_auth_creation.sh
```

### 2. Cleanup
```bash
chmod +x clean_up.sh
./clean_up.sh
```

---
**Maintained by**: [leon-maister](https://github.com/leon-maister)
