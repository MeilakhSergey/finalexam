# Connect GitHub repository to Cloud Source Repository using Cloud Console (takes time to propagate)

# Save Project Id
export PROJECT_ID=$DEVSHELL_PROJECT_ID
export REGION=europe-west4
export DOCKER_REPO=docker-repo
export REPO_NAME=github_meilakhsergey_finalexam

gcloud services enable artifactregistry.googleapis.com
gcloud services enable vmwareengine.googleapis.com
gcloud services enable cloudbuild.googleapis.com
gcloud services enable compute.googleapis.com
gcloud services enable container.googleapis.com
gcloud services enable sqladmin.googleapis.com

### 1 Creating Docker repository "docker-repo" in Artifact Registry
gcloud artifacts repositories create docker-repo --repository-format=docker \
    --location=$REGION
# Checking that it was created
#gcloud artifacts repositories list

### Build docker image

# Clone project from Cloud Source Repository
gcloud source repos clone $REPO_NAME
# Build project
cd $REPO_NAME/
mvn clean package
# Build docker image
gcloud builds submit --tag $REGION-docker.pkg.dev/$PROJECT_ID/$DOCKER_REPO/docker-image:tag1

### Check that works by using Cloud Run

### 2 Automate building of docker image
gcloud beta builds triggers create cloud-source-repositories \
    --name=dockerBuild \
    --repo=$REPO_NAME \
    --branch-pattern=master \
    --dockerfile=Dockerfile \
    --dockerfile-dir=. \
    --dockerfile-image=$REGION-docker.pkg.dev/$PROJECT_ID/$DOCKER_REPO/docker-image:tag1

## Manually change image name to "europe-west4-docker.pkg.dev/$PROJECT_ID/docker-repo/docker-image:tag1"
## because this command doesn't work properly

### 3 Manual deployment in Kubernetes
# Clone project from Cloud Source Repository
gcloud source repos clone $REPO_NAME
# Create GKE cluster
gcloud config set compute/zone $REGION-a
gcloud container clusters create gke-cluster
# Check that works
#kubectl get nodes
# Connect to GKE cluster
gcloud container clusters get-credentials gke-cluster --zone $REGION-a
# Create Kubernetes Deployment
kubectl create deployment my-app --image=$REGION-docker.pkg.dev/$PROJECT_ID/$DOCKER_REPO/docker-image:tag1
# Increase number of replicas
kubectl scale deployment my-app --replicas=3
# Check that works
#kubectl get pods

# Update Kubernetes image
kubectl set image deployment my-app *=europe-west4-docker.pkg.dev/$PROJECT_ID/docker-repo/docker-image:tag1

### 4 Automatically deploy to GKE
# Delete trigger
# Enable Kubernetes Engine in Cloud Build settings (permissions)
# Add cloudbuild.yaml
# Add k8s.yaml
# Create trigger https://cloud.google.com/build/docs/deploying-builds/deploy-gke

### 5 Expose service over Cloud Balancer
kubectl expose deployment my-app --name=my-app-service --type=LoadBalancer --port 80 --target-port 8080

### 6 Connect to Cloud SQL
#gcloud sql instances create sqldb \
#--database-version=MYSQL_8_0 \
#--cpu=2 \
#--memory=7680MB \
#--region=$REGION
## https://cloud.google.com/sql/docs/mysql/quickstart-private-ip#create-instance
# create db appDB (public and private IP)
# connection name aerial-vehicle-328606:europe-west4:sqldb
# adding application.properties, Person.java, updating pom.xml
# https://cloud.google.com/sql/docs/mysql/connect-kubernetes-engine
# Create Secret credentials
kubectl create secret generic db-secret \
  --from-literal=username=root \
  --from-literal=password=aaa111 \
  --from-literal=database=appDB
## Enable Workload Identity
##gcloud container clusters update gke-cluster \
##    --workload-pool=aerial-vehicle-328606.svc.id.goog \
##    --zone=europe-west4-a
##gcloud container node-pools update default-pool \
##    --cluster=gke-cluster \
##    --workload-metadata=GKE_METADATA
  # After deleting cluster
gcloud container clusters create gke-cluster \
    --workload-pool=aerial-vehicle-328606.svc.id.goog
  # After deleting node-pool
gcloud container node-pools create nodepool \
    --cluster=gke-cluster \
    --machine-type=e2-standard-2 \
    --workload-metadata=GKE_METADATA

## Create KSA directly in Console
kubectl apply -f service-account.yaml
## Bind GSA to KSA
gcloud iam service-accounts add-iam-policy-binding \
  --role="roles/iam.workloadIdentityUser" \
  --member="serviceAccount:aerial-vehicle-328606.svc.id.goog[default/ksa-name]" \
  sql-sa@aerial-vehicle-328606.iam.gserviceaccount.com
## Annotate KSA-name
kubectl annotate serviceaccount \
  --namespace default ksa-name \
  iam.gke.io/gcp-service-account=sql-sa@aerial-vehicle-328606.iam.gserviceaccount.com

# Alternatively using service account key file
# https://cloud.google.com/sql/docs/mysql/connect-kubernetes-engine#service-account-key
##gcloud iam service-accounts keys create key.json \
##--iam-account=cloudsql@aerial-vehicle-328606.iam.gserviceaccount.com
##kubectl create secret generic service-account-secret \
##--from-file=service_account.json=key.json

### 7 Manual SQL migration
# Add liquibase to pom
