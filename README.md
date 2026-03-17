# Kubernetes Authentication Automation (Akeyless)

This repository contains production-ready scripts to automate the trust establishment between a Kubernetes cluster and Akeyless Gateway.

## 📂 Core Components
| File | Function |
| :--- | :--- |
| k8s_auth_creation_v3.sh | **Setup**: Creates K8s namespace, ServiceAccount (Token Reviewer), and configures Akeyless Auth Method + Gateway Config. |
| clean_up.sh | **Cleanup**: Safely removes all K8s and Akeyless resources created by the setup script. |
| docs/K8s_Auth_Design... | **Documentation**: Internal security review and architectural diagram of the authentication flow. |

## 🏗 Architecture
The setup follows the **Token Reviewer** pattern:
1. A dedicated ServiceAccount is created with `system:auth-delegator` permissions.
2. The Akeyless Gateway uses this SA to verify JWTs from application pods via the K8s API.

## 🚀 Usage

### 1. Prerequisite
Ensure you have `kubectl`, `akeyless` CLI installed and your environment variable set:
```bash
export AKEYLESS_GATEWAY_URL="https://gw-gke.lm.cs.akeyless.fans/api/v1"
```

### 2. Run Setup
```bash
chmod +x k8s_auth_creation_v3.sh
./k8s_auth_creation_v3.sh
```

### 3. Cleanup
To wipe all test resources and Akeyless configs:
```bash
chmod +x clean_up.sh
./clean_up.sh
```

## ⚙️ Configuration
Variables like `TEST_NS`, `AUTH_METHOD_NAME`, and `GW_CONFIG_NAME` are defined at the top of the scripts for easy customization.

---
**Maintained by**: [leon-maister](https://github.com/leon-maister)
