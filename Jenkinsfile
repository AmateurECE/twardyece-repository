pipeline {
  agent any
  stages {
    stage('Build') {
      steps {
        checkout scm
        sh '''#!/usr/bin/flake-run
        mkdocs build
        '''
        sh '''#!/bin/bash
        mkdir -p ${HOME}/sitedata/docs
        cp -a ${WORKSPACE}/build/* ${HOME}/sitedata/docs/
        '''
      }
    }
  }

  triggers {
    githubPush()
  }
}
