#!/bin/bash

# --- UTF-8 Safety ---
export LC_ALL=C.UTF-8
export LANG=C.UTF-8

# --- ANSI Color Codes (Same as Setup Script) ---
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m' # No Color (Reset)

# --- CONFIGURATION (Must match the creation script) ---
TEST_NS="leon-k8-auth-test"
SA_NAME="gateway-token-reviewer"
SA_FILE="create_sa_gw_token_reviewer.yaml"
TOKEN_FILE="generate_token_for_sa.yaml"

# Akeyless resource names
AUTH_METHOD_NAME="/K8s/k8s-auth-leon-test"
GW_CONFIG_NAME="k8s-config-created-by-script"
GW_URL="https://gw-gke.lm.cs.akeyless.fans/api/v1"
PROFILE_NAME="default"

# Log file for cleanup tracking
LOG_FILE="cleanup_k8s_auth.log"

# --- LOGGING SETUP ---
exec > >(tee -a "$LOG_FILE") 2>&1

printf "${CYAN}--- Cleanup started at $(date) ---${NC}\n"

# --- Check gateway URL consistency ---
printf "${CYAN}Checking gateway URL consistency...${NC}\n"

if [ "$AKEYLESS_GATEWAY_URL" != "$GW_URL" ]; then
    printf "${RED}ERROR: Gateway URL mismatch detected.${NC}\n"
    echo "Environment variable AKEYLESS_GATEWAY_URL: $AKEYLESS_GATEWAY_URL"
    echo "Script variable GW_URL: $GW_URL"
    echo "Please update either the environment variable or the GW_URL value so they match."
    exit 1
fi 

printf "${GREEN}SUCCESS: Gateway URL validated.${NC}\n"


# 1. Remove Akeyless Gateway Configuration
printf "${CYAN}--- Deleting Akeyless Gateway K8s Config ---${NC}\n"

if akeyless gateway-get-k8s-auth-config --name "$GW_CONFIG_NAME" --gateway-url "$GW_URL" --profile $PROFILE_NAME >/dev/null 2>&1; then

    akeyless gateway-delete-k8s-auth-config \
        --name "$GW_CONFIG_NAME" \
        --gateway-url "$GW_URL" \
        --profile $PROFILE_NAME

    printf "${GREEN}SUCCESS: Gateway config deleted.${NC}\n"

else

    printf "${YELLOW}Gateway config '$GW_CONFIG_NAME' does not exist — skipping.${NC}\n"

fi


# 2. Remove Akeyless Auth Method
printf "${CYAN}--- Deleting Akeyless Auth Method ---${NC}\n"

if akeyless get-auth-method --name "$AUTH_METHOD_NAME" --profile $PROFILE_NAME >/dev/null 2>&1; then

    akeyless delete-auth-method \
        --name "$AUTH_METHOD_NAME" \
        --profile $PROFILE_NAME

    printf "${GREEN}SUCCESS: Auth method deleted.${NC}\n"

else

    printf "${YELLOW}Auth method '$AUTH_METHOD_NAME' does not exist — skipping.${NC}\n"

fi


# 3. Remove Kubernetes Resources
printf "${CYAN}--- Deleting Kubernetes manifests and resources ---${NC}\n"

if [ -f "$SA_FILE" ]; then
    kubectl delete -f $SA_FILE --ignore-not-found=true
    printf "${GREEN}SUCCESS: ServiceAccount manifest removed.${NC}\n"
else
    printf "${YELLOW}ServiceAccount manifest not found — skipping.${NC}\n"
fi

if [ -f "$TOKEN_FILE" ]; then
    kubectl delete -f $TOKEN_FILE --ignore-not-found=true
    printf "${GREEN}SUCCESS: Token manifest removed.${NC}\n"
else
    printf "${YELLOW}Token manifest not found — skipping.${NC}\n"
fi


# 4. Final Cleanup of the Namespace and RBAC
printf "${CYAN}--- Removing Namespace and ClusterRoleBinding ---${NC}\n"

kubectl delete clusterrolebinding role-tokenreview-binding-$TEST_NS --ignore-not-found=true
kubectl delete namespace $TEST_NS --ignore-not-found=true

printf "${GREEN}SUCCESS: Kubernetes resources removed.${NC}\n"


# 5. Remove local temporary files
printf "${CYAN}--- Cleaning up local files ---${NC}\n"

rm -f "$SA_FILE" "$TOKEN_FILE" "create_k8s_auth.log"

printf "${GREEN}SUCCESS: Local files cleaned.${NC}\n"


echo "--------------------------------------------------------"
printf "${GREEN} CLEANUP COMPLETE! System is back to original state. ${NC}\n"
echo "--------------------------------------------------------"