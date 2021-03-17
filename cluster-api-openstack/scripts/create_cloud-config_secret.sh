#!/bin/bash
# Copyright 2019 The Kubernetes Authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# This files from dddd

CAPO_SCRIPT=create_cloud-config_secret.sh
while test $# -gt 0; do
        case "$1" in
          -h|--help)
            echo "${CAPO_SCRIPT} - create a secret in current K8S cluster from an OpenStack clouds.yaml file"
            echo " "
            echo "${CAPO_SCRIPT} [options] <path/to/clouds.yaml> <cloud> <namespace>"
            echo " "
            echo "options:"
            echo "-h, --help                show brief help"
            exit 0
            ;;
          *)
            break
            ;;
        esac
done

# Check if clouds.yaml file provided
if [[ -n "${1-}" ]] && [[ $1 != -* ]] && [[ $1 != --* ]];then
  CAPO_CLOUDS_PATH="$1"
else
  echo "Error: No clouds.yaml provided"
  echo "You must provide a valid clouds.yaml script to generate a cloud.conf"
  echo ""
  exit 1
fi

# Check if os cloud is provided
if [[ -n "${2-}" ]] && [[ $2 != -* ]] && [[ $2 != --* ]]; then
  export CAPO_CLOUD=$2
else
  echo "Error: No cloud specified"
  echo "You must specify which cloud you want to use."
  echo ""
  exit 1
fi

if [[ -n "${3-}" ]] && [[ $3 != -* ]] && [[ $3 != --* ]]; then
  export SECRET_NAMESPACE=$3
else
  export SECRET_NAMESPACE="default"
fi

CAPO_YQ_TYPE=$(file "$(which yq)")
if [[ ${CAPO_YQ_TYPE} == *"Python script"* ]]; then
  echo "Wrong version of 'yq' installed, please install the one from https://github.com/mikefarah/yq"
  echo ""
  exit 1
fi

CAPO_CLOUDS_PATH=${CAPO_CLOUDS_PATH:-""}
CAPO_OPENSTACK_CLOUD_YAML_CONTENT=$(cat "${CAPO_CLOUDS_PATH}")

CAPO_CACERT_ORIGINAL=$(echo "$CAPO_OPENSTACK_CLOUD_YAML_CONTENT" | yq r - clouds.${CAPO_CLOUD}.cacert)

export OPENSTACK_CLOUD="${CAPO_CLOUD}"

# Build OPENSTACK_CLOUD_YAML_B64
CAPO_OPENSTACK_CLOUD_YAML_SELECTED_CLOUD_B64=$(echo "${CAPO_OPENSTACK_CLOUD_YAML_CONTENT}" | yq r - clouds.${CAPO_CLOUD} | yq p - clouds.${CAPO_CLOUD} | base64 --wrap=0)
export OPENSTACK_CLOUD_YAML_B64="${CAPO_OPENSTACK_CLOUD_YAML_SELECTED_CLOUD_B64}"

# Build OPENSTACK_CLOUD_CACERT_B64
OPENSTACK_CLOUD_CACERT_B64=$(echo "" | base64 --wrap=0)
if [[ "$CAPO_CACERT_ORIGINAL" != "" && "$CAPO_CACERT_ORIGINAL" != "null" ]]; then
  OPENSTACK_CLOUD_CACERT_B64=$(cat "$CAPO_CACERT_ORIGINAL"  | base64 --wrap=0)
fi
export OPENSTACK_CLOUD_CACERT_B64

cat << EOF  | kubectl apply -f -
apiVersion: v1
kind: Secret
metadata:
  name: ${CAPO_CLOUD}-cloud-config
  labels:
    clusterctl.cluster.x-k8s.io/move: "true"
  namespace: ${SECRET_NAMESPACE}
data:
  clouds.yaml: ${OPENSTACK_CLOUD_YAML_B64}
  cacert: ${OPENSTACK_CLOUD_CACERT_B64}
EOF
