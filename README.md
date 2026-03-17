# Kubernetes Authentication Automation (Akeyless)

This repository contains scripts to automate the trust establishment between a Kubernetes cluster and Akeyless Gateway.

## 📂 Core Components
| File | Function |
| :--- | :--- |
| k8s_auth_creation_v3.sh | **Setup**: Creates K8s namespace, ServiceAccount, and configures Akeyless Auth Method + Gateway Config. |
| clean_up.sh | **Cleanup**: Removes all K8s and Akeyless resources created by the setup script. |

## 🚀 Usage

### 1. Run Setup
```bash
chmod +x k8s_auth_creation_v3.sh
./k8s_auth_creation_v3.sh
```

### 2. Cleanup
```bash
chmod +x clean_up.sh
./clean_up.sh
```

---
**Maintained by**: [leon-maister](https://github.com/leon-maister)
