#!/bin/bash
set -exuo pipefail

echo "RELEASE_TAG=${RELEASE_TAG}"
echo "PATCHES_FROM=${PATCHES_FROM}"
echo "DRY_RUN=${DRY_RUN}"

RELEASE_BRANCH="coreos-hyperkube-${RELEASE_TAG}"
PATCHSET_BRANCH="${RELEASE_TAG}-patchset"

git config user.name "jenkins-kube-lifecycle"
git config user.email "jenkins-kube-lifecycle@example.com"
git remote add coreos git@github.com:coreos/kubernetes.git

# Create a release branch from vanilla upstream release tag
RB_EXISTS=$(git ls-remote coreos ${RELEASE_BRANCH})
if [ -n "${RB_EXISTS}" ]; then
    echo "Release branch ${RELEASE_BRANCH} already exists. Skipping"
else
    echo "Creating release branch: ${RELEASE_BRANCH}"
    git checkout ${RELEASE_TAG} -b ${RELEASE_BRANCH}
    if [ "${DRY_RUN}" = false ]; then
        git push coreos ${RELEASE_BRANCH}
    fi
fi
   

# Create a branch containing previous release patchset 
# TODO(pb) commented out opening a pull request with hub command until credentials are setup
if [ -n "${PATCHES_FROM}" ]; then
    git fetch coreos
    git -c "user.name=Jenkins Deploy" -c "user.email=jenkins@coreos.com" rebase coreos/${RELEASE_BRANCH} coreos/${PATCHES_FROM}
    git checkout -b ${PATCHSET_BRANCH}
    if [ "${DRY_RUN}" = false ]; then
        git push coreos ${PATCHSET_BRANCH}
    fi

    # download hub so we can open pull request
    # curl -L -O https://github.com/github/hub/releases/download/v2.3.0-pre9/hub-linux-amd64-2.3.0-pre9.tgz
    # tar -xzf hub-linux-amd64-2.3.0-pre9.tgz
    # export PATH=$PATH:$PWD/hub-linux-amd64-2.3.0-pre9/bin

    # open pull request
    # if [ "${DRY_RUN}" = false ]; then
    #    hub pull-request -b ${RELEASE_BRANCH} -h ${PATCHSET_BRANCH} -m "automated PR from 1-hyperkube-release"
    #    echo "pull request opened, merge and tag a release to start the build"
    #fi
fi

echo
echo "Release branch: https://github.com/coreos/kubernetes/tree/${RELEASE_BRANCH}"
if [ -z "${PATCHES_FROM}" ]; then
    exit 0 # Done.
fi

echo "Patchset branch: https://github.com/coreos/kubernetes/tree/${PATCHSET_BRANCH}"
echo 
echo "Open a pull-request for patchset"
echo "https://github.com/coreos/kubernetes/compare/${RELEASE_BRANCH}...coreos:${PATCHSET_BRANCH}?expand=1"
