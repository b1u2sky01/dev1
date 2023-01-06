#!/bin/bash

ACTIVATIONURL="dsm://${dsa_ip}:4120/"

# Connect to Deep Security Manager
/opt/ds_agent/dsa_control -r
/opt/ds_agent/dsa_control -a $ACTIVATIONURL "policyid:${policy_id}" "groupid:${group_id}"
