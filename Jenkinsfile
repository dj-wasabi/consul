node() {

    def err = null
    currentBuild.result = "SUCCESS"

    try {
        stage 'Checkout'
            checkout scm

        stage 'Build'
            sh 'docker build -t consul-new .'

        stage 'Run container'
            sh 'docker run -d --name consultest -p 8888:8500 -p 8887:8400 -p 8886:8300 -p 8885:53/udp consul-new -server -bootstrap -ui-dir /consul/ui'
            sh 'sudo pip install testinfra'
            sh 'sleep 5 && testinfra --connection=docker --hosts=consultest'
            sh 'docker kill consultest'
            sh 'docker rm consultest'

        gitTag()

        stage 'Docker tag & Push'
            sh 'docker tag consul-new 192.168.1.210:5000/consul:$(cat GIT_COMMIT)'
            sh 'docker tag consul-new 192.168.1.210:5000/consul:latest'
            sh 'docker push 192.168.1.210:5000/consul:$(cat GIT_COMMIT)'
            sh 'docker push 192.168.1.210:5000/consul:latest'

        stage 'cleanup'
            sh 'docker rmi 192.168.1.210:5000/consul:$(cat GIT_COMMIT)'
            sh 'docker rmi 192.168.1.210:5000/consul:latest'
            sh 'docker rmi consul-new:latest'

    }

    catch (caughtError) {
        err = caughtError
        currentBuild.result = "FAILURE"
        notifyFailed()
    }

    finally {
        if (err) {
            throw err
        }
    }
}

def notifyFailed() {
    emailext (
        subject: "FAILED: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]'",
        body: """<p>FAILED: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]':</p>
        <p>Check console output at &QUOT;<a href='${env.BUILD_URL}'>${env.JOB_NAME} [${env.BUILD_NUMBER}]</a>&QUOT;</p>""",
        replyTo: 'jenkins@dj-wasabi.nl',
        to: 'werner@dj-wasabi.nl',
        attachLog: true
    )
}

def gitTag() {
  stage 'Git Tag'
    sh 'git rev-parse HEAD | cut -c1-12 > GIT_COMMIT'
    sh '''if git rev-parse -q --verify "refs/tags/$(cat GIT_COMMIT)" >/dev/null; then
              echo "Current tag found"
          else
              git config --global user.email "jenkins@dj-wasabi.local"
              git config --global user.name "Jenkins"

              git tag -m $(cat GIT_COMMIT) -a $(cat GIT_COMMIT)
              git push --tags
          fi'''
}
