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
            sh 'bash tests/runme.sh'

        stage 'Git tag & Push'
            sh 'git rev-parse HEAD | cut -c1-12 > GIT_COMMIT'
            sh '''if git rev-parse -q --verify "refs/tags/$(cat GIT_COMMIT)" >/dev/null; then
                      echo "Current tag found"
                  else
                      git config --global user.email "jenkins@dj-wasabi.local"
                      git config --global user.name "Jenkins"

                      git tag -m $(cat GIT_COMMIT) -a $(cat GIT_COMMIT)
                      git push --tags
                  fi'''

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
        emailext body: "Project build error: ${err}" ,
            attachLog: True,
            from: 'jenkins@dj-wasabi.nl',
            replyTo: 'jenkins@dj-wasabi.nl',
            subject: 'Project build failed',
            to: 'werner@dj-wasabi.nl'
    }

    finally {
        if (err) {
            throw err
        }
    }

}
