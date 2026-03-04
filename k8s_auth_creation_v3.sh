#!/bin/bash

# --- CONFIGURATION ---
TEST_NS="leon-k8-auth-test"
SA_NAME="gateway-token-reviewer"
SA_FILE="create_sa_gw_token_reviewer.yaml"
TOKEN_FILE="generate_token_for_sa.yaml"
SECRET_NAME="sa-reviewer-token"

# --- Akeyless configuration
AUTH_METHOD_NAME="/K8s/k8s-auth-leon-test"
GW_CONFIG_NAME="k8s-config-created-by-script"
GW_URL="https://gw-gke.lm.cs.akeyless.fans/api/v1"
ROLE_NAME="/FullAccess" 
LOG_FILE="create_k8s_auth.log"

# --- LOGGING SETUP ---
exec > >(tee -a "$LOG_FILE") 2>&1

echo "--- Script started at $(date) ---"
echo "--- Checking Environment ---"

CURRENT_CTX=$(kubectl config current-context)
echo "Active context: $CURRENT_CTX"


kubectl create namespace $TEST_NS --dry-run=client -o yaml | kubectl apply -f -

cat <<EOF > $SA_FILE
apiVersion: v1
kind: ServiceAccount
metadata:
  name: $SA_NAME
  namespace: $TEST_NS
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: role-tokenreview-binding-$TEST_NS
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: system:auth-delegator
subjects:
- kind: ServiceAccount
  name: $SA_NAME
  namespace: $TEST_NS
EOF

cat <<EOF > $TOKEN_FILE
apiVersion: v1
kind: Secret
metadata:
  name: $SECRET_NAME
  namespace: $TEST_NS
  annotations:
    kubernetes.io/service-account.name: $SA_NAME
type: kubernetes.io/service-account-token
EOF

echo "--- Applying manifests ---"
kubectl apply -f $SA_FILE
kubectl apply -f $TOKEN_FILE
sleep 5

# Extract Credentials (LOGGING ADDED, LOGIC UNCHANGED)
echo "--- Extracting cluster credentials ---"

SA_JWT_TOKEN=$(kubectl get secret $SECRET_NAME -n $TEST_NS --output='go-template={{.data.token | base64decode}}')
echo "SA_JWT_TOKEN: $SA_JWT_TOKEN"

CA_CERT=$(kubectl config view --raw --minify --flatten --output='jsonpath={.clusters[].cluster.certificate-authority-data}')
echo "CA_CERT: $CA_CERT"

# We keep your original logic for HOST and ISSUER
K8S_HOST=$(kubectl config view --minify --output jsonpath='{.clusters[0].cluster.server}')
echo "K8S_HOST: $K8S_HOST"

K8S_ISSUER=$(kubectl get --raw /.well-known/openid-configuration | jq -r '.issuer' 2>/dev/null)
echo "K8S_ISSUER: $K8S_ISSUER"

if [ -z "$K8S_ISSUER" ] || [ "$K8S_ISSUER" == "null" ]; then
    echo "ERROR: Failed to fetch K8S_ISSUER."
    exit 1
fi

# 6. Create Akeyless Auth Method
echo "--- Creating Akeyless Auth Method ---"
AUTH_RESULT=$(akeyless create-auth-method-k8s --name "$AUTH_METHOD_NAME" --json)
echo "AUTH_METHOD_RESPONSE: $AUTH_RESULT"

ACCESS_ID=$(echo $AUTH_RESULT | jq -r '.access_id')
PRV_KEY=$(echo $AUTH_RESULT | jq -r '.prv_key')

echo "ACCESS_ID: $ACCESS_ID"
echo "PRV_KEY: $PRV_KEY"

akeyless assoc-role-am --role-name "$ROLE_NAME" --am-name "$AUTH_METHOD_NAME"

# 7. Configure Akeyless Gateway 
echo "--- Configuring Akeyless Gateway ---"

akeyless gateway-create-k8s-auth-config \
    --name "$GW_CONFIG_NAME" \
    --gateway-url "$GW_URL" \
    --access-id "$ACCESS_ID" \
    --signing-key "$PRV_KEY" \
    --k8s-host "$K8S_HOST" \
    --k8s-issuer "$K8S_ISSUER" \
    --k8s-ca-cert "$CA_CERT" \
    --token-reviewer-jwt "$SA_JWT_TOKEN"

if [ $? -eq 0 ]; then
    echo "--------------------------------------------------------"
    echo "  SUCCESS! Log saved to $LOG_FILE"
    echo "--------------------------------------------------------"
else
    echo "ERROR: Gateway configuration failed."
    exit 1
fi