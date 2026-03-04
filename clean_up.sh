#!/bin/bash

# --- CONFIGURATION (Must match the creation script) ---
TEST_NS="leon-k8-auth-test"
SA_NAME="gateway-token-reviewer"
SA_FILE="create_sa_gw_token_reviewer.yaml"
TOKEN_FILE="generate_token_for_sa.yaml"

# Akeyless resource names
AUTH_METHOD_NAME="/K8s/k8s-auth-leon-test"
GW_CONFIG_NAME="k8s-config-created-by-script"
GW_URL="https://gw-gke.lm.cs.akeyless.fans/"
PROFILE_NAME="btg"

# Log file for cleanup tracking
LOG_FILE="cleanup_k8s_auth.log"

# --- LOGGING SETUP ---
exec > >(tee -a "$LOG_FILE") 2>&1

echo "--- Cleanup started at $(date) ---"

# 1. Remove Akeyless Gateway Configuration
echo "--- Deleting Akeyless Gateway K8s Config ---"

if akeyless gateway-get-k8s-auth-config --name "$GW_CONFIG_NAME" --gateway-url "$GW_URL" --profile $PROFILE_NAME >/dev/null 2>&1; then
    akeyless gateway-delete-k8s-auth-config \
        --name "$GW_CONFIG_NAME" \
        --gateway-url "$GW_URL" \
		--profile $PROFILE_NAME
else
    echo "Gateway config '$GW_CONFIG_NAME' does not exist — skipping deletion"
fi


# 2. Remove Akeyless Auth Method
echo "--- Deleting Akeyless Auth Method ---"

if akeyless get-auth-method --name "$AUTH_METHOD_NAME" --profile $PROFILE_NAME >/dev/null 2>&1; then
    # Deleting the method using its full path
    akeyless delete-auth-method --name "$AUTH_METHOD_NAME" --profile $PROFILE_NAME
else
    echo "Auth method '$AUTH_METHOD_NAME' does not exist — skipping deletion"
fi


# 3. Remove Kubernetes Resources
echo "--- Deleting Kubernetes manifests and resources ---"

# Deleting by files if they exist locally
if [ -f "$SA_FILE" ]; then
    kubectl delete -f $SA_FILE --ignore-not-found=true
fi

if [ -f "$TOKEN_FILE" ]; then
    kubectl delete -f $TOKEN_FILE --ignore-not-found=true
fi


# 4. Final Cleanup of the Namespace and RBAC
echo "--- Removing Namespace and ClusterRoleBinding ---"

kubectl delete clusterrolebinding role-tokenreview-binding-$TEST_NS --ignore-not-found=true
kubectl delete namespace $TEST_NS --ignore-not-found=true


# 5. Remove local temporary files
echo "--- Cleaning up local files ---"

rm -f "$SA_FILE" "$TOKEN_FILE" "create_k8s_auth.log"

echo "--------------------------------------------------------"
echo "  CLEANUP COMPLETE! System is back to original state.  "
echo "--------------------------------------------------------"