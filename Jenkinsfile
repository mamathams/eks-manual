pipeline {
  agent any

  options {
    timestamps()
    disableConcurrentBuilds()
  }

  triggers {
    githubPush()
  }

  parameters {
    choice(name: 'ACTION', choices: ['apply', 'destroy'], description: 'Terraform action')
    booleanParam(name: 'AUTO_APPLY', defaultValue: false, description: 'Skip manual approval for apply only')
    string(name: 'AWS_REGION', defaultValue: 'us-east-1', description: 'AWS region')
    string(name: 'EXPECTED_ACCOUNT_ID', defaultValue: '136191772987', description: 'Fail if account mismatch')
    booleanParam(name: 'MANAGE_K8S_RESOURCES', defaultValue: true, description: 'Manage in-cluster resources (namespace/pod) via Terraform')
  }

  environment {
    TF_IN_AUTOMATION = 'true'
    TF_INPUT = '0'
    TF_CLI_ARGS = '-no-color'
    AWS_REGION = "${params.AWS_REGION}"
    AWS_DEFAULT_REGION = "${params.AWS_REGION}"
    TF_VAR_region = "${params.AWS_REGION}"
    TF_VAR_manage_kubernetes_resources = "${params.MANAGE_K8S_RESOURCES}"
  }

  stages {
    stage('Checkout') {
      steps {
        checkout scm
      }
    }

    stage('Precheck AWS Identity') {
      steps {
        withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-creds']]) {
          script {
            if (isUnix()) {
              sh '''#!/usr/bin/env bash
                set -euo pipefail
                ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
                echo "Current AWS Account: ${ACCOUNT_ID}"
                [ "${ACCOUNT_ID}" = "${EXPECTED_ACCOUNT_ID}" ] || { echo "ERROR: account mismatch"; exit 1; }
              '''
            } else {
              bat '''
                @echo off
                for /f %%i in ('aws sts get-caller-identity --query Account --output text') do set ACCOUNT_ID=%%i
                echo Current AWS Account: %ACCOUNT_ID%
                if /I not "%ACCOUNT_ID%"=="%EXPECTED_ACCOUNT_ID%" exit /b 1
              '''
            }
          }
        }
      }
    }

    stage('Terraform Init') {
      steps {
        withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-creds']]) {
          script {
            if (isUnix()) {
              sh 'terraform init -input=false'
            } else {
              bat 'terraform init -input=false'
            }
          }
        }
      }
    }

    stage('Update kubeconfig') {
      steps {
        withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-creds']]) {
          script {
            if (isUnix()) {
              sh '''#!/usr/bin/env bash
                set -euo pipefail
                if aws eks describe-cluster --region us-east-1 --name manual-eks-cluster >/dev/null 2>&1; then
                  aws eks update-kubeconfig --region us-east-1 --name manual-eks-cluster
                else
                  echo "EKS cluster manual-eks-cluster not found yet; skipping kubeconfig update."
                fi
              '''
            } else {
              bat '''
                @echo off
                aws eks describe-cluster --region us-east-1 --name manual-eks-cluster >NUL 2>NUL
                if %ERRORLEVEL%==0 (
                  aws eks update-kubeconfig --region us-east-1 --name manual-eks-cluster
                ) else (
                  echo EKS cluster manual-eks-cluster not found yet; skipping kubeconfig update.
                )
              '''
            }
          }
        }
      }
    }

    stage('Terraform Plan') {
      steps {
        withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-creds']]) {
          script {
            if (isUnix()) {
              if (params.ACTION == 'destroy') {
                sh '''#!/usr/bin/env bash
                  set -euo pipefail
                  export TF_VAR_manage_kubernetes_resources=false
                  # If the Kubernetes API is unreachable, these resources can block destroy.
                  # Remove them from state before planning a destroy.
                  terraform state rm -lock-timeout=5m kubernetes_pod_v1.app[0] kubernetes_namespace_v1.pod_ns[0] || true
                '''
                sh 'TF_VAR_manage_kubernetes_resources=false terraform plan -destroy -input=false -out=tfplan'
              } else {
                sh 'terraform plan -input=false -out=tfplan'
              }
            } else {
              if (params.ACTION == 'destroy') {
                bat '''
                  @echo off
                  set TF_VAR_manage_kubernetes_resources=false
                  terraform state rm -lock-timeout=5m kubernetes_pod_v1.app[0] kubernetes_namespace_v1.pod_ns[0]
                  exit /b 0
                '''
                bat 'set TF_VAR_manage_kubernetes_resources=false&& terraform plan -destroy -input=false -out=tfplan'
              } else {
                bat 'terraform plan -input=false -out=tfplan'
              }
            }
          }
        }
      }
    }

    stage('Approval') {
      when {
        expression { return params.ACTION == 'destroy' || !params.AUTO_APPLY }
      }
      steps {
        timeout(time: 20, unit: 'MINUTES') {
          script {
            if (params.ACTION == 'destroy') {
              input message: 'Proceed with terraform destroy?', ok: 'Destroy'
            } else {
              input message: 'Proceed with terraform apply?', ok: 'Apply'
            }
          }
        }
      }
    }

    stage('Terraform Execute') {
      steps {
        withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-creds']]) {
          script {
            if (isUnix()) {
              if (params.ACTION == 'destroy') {
                sh 'TF_VAR_manage_kubernetes_resources=false terraform apply -input=false -auto-approve tfplan'
              } else {
                sh 'terraform apply -input=false -auto-approve tfplan'
              }
            } else {
              if (params.ACTION == 'destroy') {
                bat 'set TF_VAR_manage_kubernetes_resources=false&& terraform apply -input=false -auto-approve tfplan'
              } else {
                bat 'terraform apply -input=false -auto-approve tfplan'
              }
            }
          }
        }
      }
    }
  }

  post {
    always {
      script {
        if (fileExists('tfplan')) {
          archiveArtifacts artifacts: 'tfplan'
        } else {
          echo 'No tfplan file to archive in this run.'
        }
      }
    }
  }
}
