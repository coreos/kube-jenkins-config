// META
repo = "coreos/kube-jenkins-config"

// CONFIG
org_whitelist = ['coreos', 'coreos-inc']
job_admins = ['colemickens', 'ericchiang', 'rithujohn191', 'rphillips']
user_whitelist = job_admins

// JOBS
job_name = "tku-1-release-hyperkube"

pipelineJob(job_name) {
  parameters {
    stringParam('JENKINS_BRANCH', 'master', 'OPTIONAL: branch containing Jenkinsfile')
    stringParam('RELEASE_TAG', '', 'REQUIRED: Upstream release tag')
    stringParam('PATCHES_FROM', '', 'OPTIONAL: If set, will re-apply the patchset from this branch in github.com/coreos/kubernetes')
    booleanParam('DRY_RUN', true, 'Do not push to any github repos')
  }
  definition {
    cpsScm {
      scm {
        git {
          remote {
            github("${repo}")
            refspec('+refs/heads/*:refs/remotes/origin/* +refs/pull/*:refs/remotes/origin/pr/*')
          }
          branch('${JENKINS_BRANCH}')
        }
      }
      scriptPath('pipelines/hyperkube-pr/Jenkinsfile')
    }
  }
}
