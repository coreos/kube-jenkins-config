// META
repo = "coreos/kube-jenkins-config"

// JOBS
job_name = "tku-2-release-hyperkube"

pipelineJob(job_name) {
  parameters {
    stringParam('JENKINS_BRANCH', 'master', 'REQUIRED: branch containing Jenkinsfile')
    stringParam('KUBERNETES_VERSION', 'master', 'REQUIRED: git ref or tag to build')
    booleanParam('PUSH_IMAGE', false)
  }
  definition {
    cpsScm {
      scm {
        git {
          remote {
            github("${repo}")
            refspec('+refs/heads/*:refs/remotes/origin/* +refs/pull/*:refs/remotes/origin/pr/*')
            credentials('github_userpass')
          }
          branch('${JENKINS_BRANCH}')
        }
      }
      scriptPath('pipelines/hyperkube-release/Jenkinsfile')
    }
  }
}
