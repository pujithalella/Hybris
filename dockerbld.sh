#!/bin/bash
###############################################################################
######      Description: Script is used to build a docker image          ######
######                       Author:Pujitha                              ######
######          Usage: dockerhybbld-test.sh <<build state>>              ######
###############################################################################

TIME=$(date '+%Y%m%d_%H%M%s')
echo "Current time: $TIME"

docker_build_dir='/ACN/home/hybris/docker/hybris-build/DOCKERBUILD'
docker_build_image='/ACN/home/hybris/docker/hybris-build/DOCKERIMAGES'
function logdate() {
  echo "- $(date '+%Y%m%d-%H%M%S')[INFO]     $1"
}

function logError() {
  echo "- $(date '+%Y%m%d-%H%M%S')[ERROR]    $1"
  exit 1
}

function prebuild() {
  logdate "Pulling Hyb from Nexus"
#  cd ${docker_build_dir}/resources/
#  wget --trust-server-names 'http://nexus/nexus/service/local/artifact/maven/redirect?r=thirdparty&g=sap.hybris&a=hybriscomm&v=6300p_5-70002554_ACN&e=tgz' || logError "Failed to pull"
  logdate "Succesfully Pulled hyb from nexus"
  logdate "Pulling Java from Nexus"
#  wget --trust-server-names 'http://nexus/nexus/service/local/artifact/maven/redirect?r=thirdparty&g=com.oracle&a=jdk&v=8u171-linux&e=tar.gz&c=x64' ${docker_build_dir}/resources  || logError "Failed to pull"
  logdate "Successfully pulled java from nexus"

}

function build() {
  logdate "Docker Image Build"
  cd ${docker_build_dir}
  docker build --iidfile /tmp/test2.sh -t hybris/platform:63-5_061118 . || logError "Build Failed"
  NEW_IMAGE_ID=$(cat /tmp/test2.sh | cut -f2 -d: | cut -c -12)
  logdate "My new image ID is ${NEW_IMAGE_ID}"
# docker save ${NEW_IMAGE_ID} | gzip > ${docker_build_image}/${BLD_TAR_NAME}.tar.gz
# logdate "New tar file ${BLD_TAR_NAME}.tar.gz is created"
}

P_STATE=false
B_STATE=false
BLD_TAR_NAME=""
while getopts "pbt:" bld; do
  case ${bld} in
    p)
      P_STATE=true
      BLD_STATE=prebuild
      ;;
    b)
      B_STATE=true
      BLD_STATE=build
      ;;
    t)
      BLD_TAR_NAME=$OPTARG
      ;;
    \?)
      logError "Must pass -p or -b and -t"
      ;;
    :)
      logError "You must pass value for -${bld}"
      ;;
  esac
done
shift $((OPTIND -1))

[[ "${P_STATE}" == "true" && "${B_STATE}" == "true" ]] && logError "You should pass -p or -b"
[[ "${P_STATE}" == "false" && "${B_STATE}" == "false" ]] && logError "You should pass -p or -b"
[[ "${BLD_STATE}" == "build" && -z ${BLD_TAR_NAME} ]] && logError "You must pass -t<<tar-name>> for build"
[[ ! -z "${BLD_TAR_NAME}" ]] && logdate "Using the name for tar ${BLD_TAR_NAME}.tar.gz"

logdate "Performing the action:${BLD_STATE}"
#$BLD_STATE
