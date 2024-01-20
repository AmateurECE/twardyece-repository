pipeline {
  agent any
  stages {
    stage('Build') {
      steps {
        checkout scm
        sh '''#!/usr/bin/flake-run
        mkdocs build
        '''
        sh "cp -a ${WORKSPACE}/repository ${HOME}/"
      }
    }
  }

  triggers {
    githubPush()
  }
}
