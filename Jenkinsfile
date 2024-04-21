pipeline {
    agent any
    
    environment {
        GCP_PROJECT_ID = "vasmi-cloud"
        BUILD_ID = "${env.BUILD_ID}"
        GCP_SA_KEY = credentials('sql-creds') // Jenkins credentials for GCP service account key
        GCR_REPO_NAME = "us-central1-docker.pkg.dev/vamsi-cloud/docker-repo"
        GKE_CLUSTER_NAME = "vamsi-gke-dev-new"
        GKE_ZONE = "asia-east1-a	"
        K8S_NAMESPACE = "petclinic"

    }
    
    stages {

         stage('Copy SQL Json') {
            steps {
                withCredentials([file(credentialsId: 'sql-creds', variable: 'SECRET_SQL_FILE')]) {
                
                    sh "cat $SECRET_SQL_FILE > sql-creds.json"  
            }
        }
    }
        stage('Build') {
            steps {
                script {
                    // Build your Spring Boot application
                    sh './mvnw -DskipTests clean package'
                    sh 'ls'
                }
            }
        }
        
        stage('Build Docker Image') {
            steps {
                script {
                    // Build Docker image
                   sh 'docker build -t ${GCR_REPO_NAME}/petclinic:latest .'
                   sh 'docker build -t ${GCR_REPO_NAME}/petclinic:${BUILD_ID} .'
                    
                }
            }
        }
        
        stage('Push Docker Image to Google Artifact Registry') {
            steps {
                script {
                    // Authenticate to GCR
                    withCredentials([file(credentialsId: 'sql-creds', variable: 'GOOGLE_APPLICATION_CREDENTIALS')]) {
                        sh 'gcloud auth activate-service-account --key-file=$GOOGLE_APPLICATION_CREDENTIALS'
                    }
                     sh 'gcloud auth configure-docker us-central1-docker.pkg.dev'
                    // Push Docker image to GCR
                    sh "docker push ${GCR_REPO_NAME}/petclinic:latest"
                    sh "docker push ${GCR_REPO_NAME}/petclinic:${BUILD_ID}"
                }
            }
        }
        
        stage('Deploy to Google Kubernetes Engine') {
            steps {
                script {
                    // Set GKE cluster context
                    sh "gcloud container clusters get-credentials ${GKE_CLUSTER_NAME} --zone ${GKE_ZONE} --project ${GCP_PROJECT_ID}"
                    
                    // Apply Kubernetes deployment
                    sh "kubectl apply -f manifest/kube.yaml --namespace=${K8S_NAMESPACE} --record"
                    
                    // Wait for deployment rollout to complete
                    timeout(time: 10, unit: 'minutes') {
                       
                    }
                }
            }
        }
    }
}
