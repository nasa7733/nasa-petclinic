pipeline {
    agent any
    
    environment {
        GCP_PROJECT_ID = "vasmi-cloud"
        BUILD_ID = "${env.BUILD_ID}"
        GCP_SA_KEY = credentials('sql-creds') // Jenkins credentials for GCP service account key
        GCR_IMAGE_NAME = "us-central1-docker.pkg.dev/vamsi-cloud/docker-repo"
        GKE_CLUSTER_NAME = "your-gke-cluster-name"
        GKE_ZONE = "your-gke-zone"
        K8S_NAMESPACE = "your-kubernetes-namespace"
        K8S_DEPLOYMENT_NAME = "your-deployment-name"
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
                    docker.build(GCR_IMAGE_NAME)
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
                    
                    // Push Docker image to GCR
                    sh "docker push ${GCR_IMAGE_NAME}:latest"
                    sh "docker push ${GCR_IMAGE_NAME}:${BUILD_ID}"
                }
            }
        }
        
        stage('Deploy to Google Kubernetes Engine') {
            steps {
                script {
                    // Set GKE cluster context
                    sh "gcloud container clusters get-credentials ${GKE_CLUSTER_NAME} --zone ${GKE_ZONE} --project ${GCP_PROJECT_ID}"
                    
                    // Apply Kubernetes deployment
                    sh "kubectl apply -f kubernetes/deployment.yaml --namespace=${K8S_NAMESPACE} --record"
                    
                    // Wait for deployment rollout to complete
                    timeout(time: 10, unit: 'minutes') {
                        sh "kubectl rollout status deployment/${K8S_DEPLOYMENT_NAME} --namespace=${K8S_NAMESPACE}"
                    }
                }
            }
        }
    }
}
