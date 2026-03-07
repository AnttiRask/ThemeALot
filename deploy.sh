#!/bin/bash
# ThemeALot - Cloud Run Deployment Script
# Deploys to: https://themealot.youcanbeapirate.com

set -e

# Configuration
PROJECT_ID="chrome-duality-445915-b5"
SERVICE_NAME="themalot"
REGION="europe-north1"
MEMORY="1Gi"
CPU="1"
TIMEOUT="300"
PORT="8080"

echo "=== ThemeALot Cloud Run Deployment ==="
echo "Project:  $PROJECT_ID"
echo "Service:  $SERVICE_NAME"
echo "Region:   $REGION"
echo ""

# Check if gcloud is authenticated
if ! gcloud auth list --filter=status:ACTIVE --format="value(account)" | head -n1 > /dev/null 2>&1; then
    echo "Error: Not authenticated with gcloud. Run 'gcloud auth login' first."
    exit 1
fi

# Deploy to Cloud Run
echo "Starting deployment..."
gcloud run deploy "$SERVICE_NAME" \
    --source . \
    --region "$REGION" \
    --project "$PROJECT_ID" \
    --allow-unauthenticated \
    --memory "$MEMORY" \
    --cpu "$CPU" \
    --timeout "$TIMEOUT" \
    --port "$PORT"

echo ""
echo "=== Deployment Complete ==="
echo "Service URL: https://themealot.youcanbeapirate.com"
echo ""

# Show latest revision
echo "Latest revision:"
gcloud run revisions list \
    --service "$SERVICE_NAME" \
    --region "$REGION" \
    --project "$PROJECT_ID" \
    --limit 1
