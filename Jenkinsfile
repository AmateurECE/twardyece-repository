node {
    stage('Build') {
        checkout scm
        sh 'mkdocs build'
        sh "cp -a ${WORKSPACE}/repository ${HOME}/"
    }
}
