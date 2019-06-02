#!groovy

pipeline {
  options {
    buildDiscarder(logRotator(numToKeepStr: '5'))
    disableConcurrentBuilds()
  }
  environment {
      NEXUS_USERNAME = credentials('NEXUS_USERNAME')
      NEXUS_PASSWORD = credentials('NEXUS_PASSWORD')
      NEXUS_HOSTNAME = credentials('NEXUS_HOSTNAME')
      SONAR_TOKEN = credentials('SONAR_TOKEN')
      SONAR_HOSTNAME = credentials('SONAR_HOSTNAME')
   }
  agent any
  stages {
    stage('Build') {
      steps {
        script {
          sh '''
            SBI/build.sh
          '''
        }
      }
    }
    stage('Test') {
      steps {
        script {
          sh '''
            SBI/test.sh
          '''
        }
      }
    }
    stage('Clover') {
      when {
        expression {
          fileExists("jenkins-test-results/clover.xml")
        }
      }
      steps {
        step([
          $class: 'CloverPublisher',
          cloverReportDir: 'jenkins-test-results',
          cloverReportFileName: 'clover.xml',
          healthyTarget: [methodCoverage: 70, conditionalCoverage: 80, statementCoverage: 80], // optional, default is: method=70, conditional=80, statement=80
        ])
      }
    }
    stage('Cobertura Report') {
    when {
        expression {
          fileExists("**/coverage.xml")
        }
      }
      steps {
       // junit '**/junit.xml'
        step([$class: 'CoberturaPublisher', 
                autoUpdateHealth: false, 
                autoUpdateStability: false, 
                coberturaReportFile: '**/coverage.xml', 
                failUnhealthy: false, 
                failUnstable: false, 
                maxNumberOfBuilds: 0, onlyStable: false, sourceEncoding: 'ASCII', 
                zoomCoverageChart: false
               ])
      }
    }
    stage('TAP') {
      steps {
        step([$class: "TapPublisher", testResults: "jenkins-test-results/*.tap"])
      }
    }
    stage('Sonarqube') {
    environment {
        scannerHome = tool 'SonarQubeScanner'
    }
    steps {
        withSonarQubeEnv('SonarQube') {
            sh "${scannerHome}/bin/sonar-scanner"
        }
        timeout(time: 2, unit: 'MINUTES') {
            waitForQualityGate abortPipeline: true
        }
    }
}
    stage('Container Build') {
      when {
        environment name: 'CHANGE_ID', value: ''
        expression {
          fileExists("SBI/dockerize.sh")
        }
      }
      steps {
        script {
          sh '''
            SBI/dockerize.sh
          '''
        }
      }
    }
    stage('Deploy') {
      when {
        environment name: 'CHANGE_ID', value: ''
        expression {
          fileExists("SBI/service-manifest.txt")
        }
      }
      steps {
        script {
          def services = readFile('SBI/service-manifest.txt').readLines()
          for (int i = 0; i < services.size(); i++) {
            def fields = services[i].split( ':' )
            if (fields.size() == 2) {
              def (service,type) = fields
              def jobname = 'Deployment/Deploy ' + type + ' Service'
              println('Deploying via ' + jobname + ' for service ' + service)
              build job: jobname,
                parameters: [
                  string(name: 'BRANCH', value: env.BRANCH_NAME),
                  string(name: 'SERVICE', value: service)
                ],
                wait: false
            } else {
              println('Skipping invalid service manifest entry: ' + services[i])
            }
          }
        }
      }
    }
  }
  post {
    always {
      script {
        currentBuild.result = currentBuild.currentResult
      }
    }
    fixed {
      emailext (attachLog: true, body: "${currentBuild.result}: ${BUILD_URL}", compressLog: true, 
                subject: "Jenkins build back to normal: ${currentBuild.fullDisplayName}", 
              //  recipientProviders: [[$class: 'CulpritsRecipientProvider'],[$class: 'RequesterRecipientProvider']],
                to: 'smandal@rythmos.com')
    }
    failure {
      // notify users when the Pipeline fails
      emailext (attachLog: true,
                body: "${currentBuild.result}: ${BUILD_URL}", compressLog: true, 
                subject: "Build failed in Jenkins: ${currentBuild.fullDisplayName}", 
              //  recipientProviders: [[$class: 'CulpritsRecipientProvider'],[$class: 'RequesterRecipientProvider']],
                to: 'smandal@rythmos.com')
    }
    unstable {
      // notify users when the Pipeline unstable
      emailext (attachLog: true, body: "${currentBuild.result}: ${BUILD_URL}", compressLog: true, 
                subject: "Unstable Pipeline: ${currentBuild.fullDisplayName}", 
               // recipientProviders: [[$class: 'CulpritsRecipientProvider'],[$class: 'RequesterRecipientProvider']],
                to: 'smandal@rythmos.com')
    }
  }
}
