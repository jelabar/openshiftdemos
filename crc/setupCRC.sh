#!/bin/bash

#https://medium.com/@jeesmon/steps-to-install-an-operator-from-command-line-in-openshift-9473039bc92e
export USER=kubeadmin
export PASSWORD=T4m4r1nd018
export OPERATOR_NAME=local-storage-operator
if [[ -e ~/.crc/bin/crc ]]; then 
  eval $(crc oc-env)
fi

oc login -u $USER -p $PASSWORD https://api.crc.testing:6443
#oc get packagemanifests -n openshift-marketplace

#Install local storage Operator
#Get catalog source  -- namespace is optional
CATALOG_SOURCE="$(oc get packagemanifests ${OPERATOR_NAME} -n openshift-marketplace -o jsonpath={.status.catalogSource})"
#redhat-operators

#Get catalog source namespace
CATALOG_SOURCE_NAMESPACE="$(oc get packagemanifests ${OPERATOR_NAME} -n openshift-marketplace -o jsonpath={.status.catalogSourceNamespace})"
#openshift-marketplace

#Get channel
CHANNEL="$(oc get packagemanifests ${OPERATOR_NAME} -n openshift-marketplace -o jsonpath="{range .status.channels[*]}{.name}{'\n'}{end}")"
#stable 

#Get CSV
CSV="$(oc get packagemanifests ${OPERATOR_NAME} -n openshift-marketplace -o jsonpath="{range .status.channels[*]}{.currentCSV}{'\n'}{end}")"
#local-storage-operator.v4.13.0-202309040902

echo -e  > local-storage-operator.yaml << EOF \
"apiVersion: operators.coreos.com/v1alpha1 \n \
kind: Subscription \n \
metadata: \n \
  name: ${OPERATOR_NAME} \n \
  namespace: anything \n \
spec: \n \
  channel: ${CHANNEL} \n \
  installPlanApproval: Automatic \n \
  name: ${OPERATOR_NAME} \n \
  source: ${CATALOG_SOURCE} \n \
  sourceNamespace: ${CATALOG_SOURCE_NAMESPACE} \n \
  startingCSV: ${CSV}"
EOF

oc apply -f local-storage-operator.yaml