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
    booleanParam(name: 'FORCE_RUN', defaultValue: false, description: 'Run even when no Terraform files changed')
    string(name: 'AWS_REGION', defaultValue: 'us-east-1', description: 'AWS region')
    string(name: 'EXPECTED_ACCOUNT_ID', defaultValue: '136191772987', description: 'Fail if account mismatch')
  }

  environment {
    TF_IN_AUTOMATION = 'true'
    TF_INPUT = '0'
    TF_CLI_ARGS = '-no-color'
    AWS_REGION = "${params.AWS_REGION}"
    AWS_DEFAULT_REGION = "${params.AWS_REGION}"
    TF_VAR_region = "${params.AWS_REGION}"
  }

  stages {
    stage('Checkout') {
      steps {
        checkout scm
      }
    }

    stage('Terraform Gate') {
      when {
        not {
          anyOf {
            expression { return params.FORCE_RUN }
            changeset "**/*.tf"
            changeset "**/*.tfvars"
            changeset "**/.terraform.lock.hcl"
          }
        }
      }
      steps {
        script {
          if (currentBuild.previousBuild == null) {
            echo 'First build detected (empty changelog). Continuing without Terraform changeset check.'
          } else {
            error('No Terraform file changes detected. Set FORCE_RUN=true to run anyway.')
          }
        }
      }
    }

    stage('Precheck AWS Identity') {
      when {
        anyOf {
          expression { return params.FORCE_RUN }
          changeset "**/*.tf"
          changeset "**/*.tfvars"
          changeset "**/.terraform.lock.hcl"
        }
      }
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
      when {
        anyOf {
          expression { return params.FORCE_RUN }
          changeset "**/*.tf"
          changeset "**/*.tfvars"
          changeset "**/.terraform.lock.hcl"
        }
      }
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

    stage('Terraform Plan') {
      when {
        anyOf {
          expression { return params.FORCE_RUN }
          changeset "**/*.tf"
          changeset "**/*.tfvars"
          changeset "**/.terraform.lock.hcl"
        }
      }
      steps {
        withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-creds']]) {
          script {
            if (isUnix()) {
              if (params.ACTION == 'destroy') {
                sh 'terraform plan -destroy -input=false -out=tfplan'
              } else {
                sh 'terraform plan -input=false -out=tfplan'
              }
            } else {
              if (params.ACTION == 'destroy') {
                bat 'terraform plan -destroy -input=false -out=tfplan'
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
        allOf {
          anyOf {
            expression { return params.FORCE_RUN }
            changeset "**/*.tf"
            changeset "**/*.tfvars"
            changeset "**/.terraform.lock.hcl"
          }
          expression { return params.ACTION == 'destroy' || !params.AUTO_APPLY }
        }
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
      when {
        anyOf {
          expression { return params.FORCE_RUN }
          changeset "**/*.tf"
          changeset "**/*.tfvars"
          changeset "**/.terraform.lock.hcl"
        }
      }
      steps {
        withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-creds']]) {
          script {
            if (isUnix()) {
              sh 'terraform apply -input=false -auto-approve tfplan'
            } else {
              bat 'terraform apply -input=false -auto-approve tfplan'
            }
          }
        }
      }
    }
  }

  post {
    always {
      archiveArtifacts artifacts: 'tfplan', allowEmptyArchive: true
    }
  }
}
