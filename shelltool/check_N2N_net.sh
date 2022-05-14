#!/bin/bash

#eths=$(ifconfig -a | awk !/lo/'{print $1}'|awk !/br/ | awk /:/| sed 's/.$//g')
host_ip=10.239.52.91
remote_sut_ip=192.168.122.44
remote_gene_ip=10.239.115.83

sut_eths=(enp0s4 enp0s5 enp0s6 enp0s7)
gene_eths=(enp175s0f0 enp177s0f0 enp24s0f0 enp26s0f0)

#echo ${sut_nics[*]}

N=${#sut_eths[*]}
M=${#gene_eths[*]}


for((i=0;i<N;i++))
do
    for((j=0;j<=i;j++))
        do
            ssh $
        done
done

ssh $remote_gene_ip << EOF
ifconfig ${gene_eths[0]} 192.168.10.1
EOF

ssh $remote_sut_ip << EOF
ifconfig ${sut_eths[0]} 192.168.10.2
EOF·

ssh $remote_gene_ip << EOF
ping 192.168.10.2 
# if ret is not good , then 
EOF

## output the format result