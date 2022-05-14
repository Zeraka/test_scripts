#!/bin/bash

work_node_ip=10.239.183.142:6443
token=fab022.oohgvy5e36mh7x40
ca_hash=984e7bfb7b1742a37173b6a3f92b4a2aedef46c77a27ad9a67d598781a108581
kubeadm join $work_node_ip --token $token --discovery-token-ca-cert-hash sha256:$ca_hash
