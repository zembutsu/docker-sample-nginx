pipeline {
  agent {
    label "jenkins-maven"
  }
  environment {
    ORG = 'romil-punetha'
    APP_NAME = 'docker-sample-nginx'
    CHARTMUSEUM_CREDS = credentials('jenkins-x-chartmuseum')
  }
  stages {
    stage('CI Build and push snapshot') {
      when {
        branch 'PR-*'
      }
      environment {
        PREVIEW_VERSION = "0.0.0-SNAPSHOT-$BRANCH_NAME-$BUILD_NUMBER"
        PREVIEW_NAMESPACE = "$APP_NAME-$BRANCH_NAME".toLowerCase()
        HELM_RELEASE = "$PREVIEW_NAMESPACE".toLowerCase()
      }
      steps {
        container('maven') {
          sh "skaffold version"
          sh "export VERSION=$PREVIEW_VERSION && skaffold build -f skaffold.yaml"
          dir('charts/docker-sample-nginx') {
            sh "jx step helm build"
          }
        }
      }
    }
    stage('Build Release') {
      when {
        branch 'master'
      }
      steps {
        container('maven') {

          // ensure we're not on a detached head
          sh "git checkout master"
          sh "git config --global credential.helper store"
          sh "jx step git credentials"

          // so we can retrieve the version in later steps
          sh "echo \$(jx-release-version) > VERSION"
          sh "skaffold version"
          sh "export VERSION=`cat VERSION` && skaffold build -f skaffold.yaml"
          dir('charts/docker-sample-nginx') {

            // Let's build chart
            sh "jx step helm build --verbose"

            // Let's create tag in Git
            sh "jx step tag --version \$(cat ../../VERSION)"
          }
        }
      }
    }
    stage('Promote to Environments') {
      when {
        branch 'master'
      }
      steps {
        container('maven') {
          dir('charts/docker-sample-nginx') {
            sh "jx step changelog --version v\$(cat ../../VERSION)"

            // Let's release the helm chart
            sh "jx step helm release"

            // Let's promote through all 'Auto' promotion Environments
            sh "jx promote -b --all-auto --timeout 1h --version \$(cat ../../VERSION)"
          }
        }
      }
    }
  }
  post {
        always {
          cleanWs()
        }
  }
}
