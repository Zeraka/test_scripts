#!/bin/bash

#eths=$(ifconfig -a | awk !/lo/'{print $1}'|awk !/br/ | awk /:/| sed 's/.$//g')
host_ip=10.239.52.91
remote_sut_ip=192.168.122.44
remote_gene_ip=10.239.115.83
remote_sut_user=root
remote_gene_user=root
sut_eths=(enp0s6 enp0s7 enp0s8 enp0s9)
gene_eths=(enp175s0f0 enp177s0f0 enp24s0f0 enp26s0f0)

remote_sut=$remote_sut_user@$remote_sut_ip
remote_gene=$remote_gene_user@$remote_gene_ip


N=${#sut_eths[*]}

status_sut=(0 0 0 0)
status_gene=(0 0 0 0)


echo "gene	sut" > checklog

if [[ $host_ip == remote_sut_ip ]] || [[ $host_ip == $remote_gene_ip ]];then
	if [[ $host_ip == remote_sut_ip ]];then
		remote_ip=$remote_sut_ip
		remote_user=$remote_sut_user
	else
		remote_ip=$remote_gene_ip
		remote_ip=$remote_gene_user
	fi
		remote=$remote_user@$remote_user
		host=root@$host_ip
	ip_3rd=1
	for((i=0;i<$N;i++))
	do
        if [[ ${status_remote[$i]} == "1" ]];then
                continue;
        fi

        for((j=0;j<=$N;j++))
        do
                if [[ ${status_host[$j]} == "1" ]];then
                        continue;
                fi

                host_ip_test=192.168.$ip_3rd.1
                remote_ip_test=192.168.$ip_3rd.2
                ifconfig ${host_eths[$i]} $host_ip_test
                ssh $remote "ifconfig ${remote_eths[$j]} $remote_ip_test"
                ssh $remote "ping -c 10 $host_ip_test > remote_ping_host.log"
                #ping -c 10 $remote_ip_test > host_ping_remote.log"
                scp $remote:/root/remote_ping_host.log .

                gene_ping_sut=`sed -n "3p" remote_ping_host.log`
                #host_ping_remote=`sed -n "3p" host_ping_remote.log`
                if [[ $remote_ping_host =~ "Host Unreachable" ]] || [[ -z $remote_ping_host ]];then
                        echo "${remote_eths[$i]} is not linked with ${host_eths[$j]}"
                elif [[ $remote_ping_host =~ "ttl=" ]];then
                        echo "${remote_eths[$i]} is linked with ${host_eths[$j]}"
                        echo  "${remote_eths[$i]} ${host_eths[$j]}" >>  checklog
                        status_remote[$i]=1
                        status_host[$j]=1
                        ssh $remote "ifconfig ${gene_eths[$i]} 0"
                        ifconfig ${sut_eths[$j]} 0
                        let ip_3rd++
                        break
                fi

                let ip_3rd++
                ssh $remote "ifconfig ${gene_eths[$i]} 0"
                ifconfig ${sut_eths[$j]} 0


        done
done

	

else
ip_3rd=1
for((i=0;i<$N;i++))
do
	if [[ ${status_gene[$i]} == "1" ]];then
		continue;
	fi

	for((j=0;j<=$N;j++))
	do	
		if [[ ${status_sut[$j]} == "1" ]];then
			continue;
		fi

		gene_ip_test=192.168.$ip_3rd.1
		sut_ip_test=192.168.$ip_3rd.2
		ssh $remote_gene "ifconfig ${gene_eths[$i]} $gene_ip_test"
		ssh $remote_sut "ifconfig ${sut_eths[$j]} $sut_ip_test"
		ssh $remote_gene "ping -c 10 $sut_ip_test > gene_ping_sut.log"
		#ssh $remote_sut "ping -c 10 $gene_ip_test > sut_ping_gene.log"
		scp $remote_gene:/root/gene_ping_sut.log .
		#scp $remote_sut:/root/sut_ping_gene.log .
		
		gene_ping_sut=`sed -n "3p" gene_ping_sut.log`
		#sut_ping_gene=`sed -n "3p" sut_ping_gene.log`
		if [[ $gene_ping_sut =~ "Host Unreachable" ]] || [[ -z $gene_ping_sut ]];then
			echo "${gene_eths[$i]} is not linked with ${sut_eths[$j]}"
		elif [[ $gene_ping_sut =~ "ttl=" ]];then
			echo "${gene_eths[$i]} is linked with ${sut_eths[$j]}"
			echo  "${gene_eths[$i]}	${sut_eths[$j]}" >>  checklog
			status_gene[$i]=1
			status_sut[$j]=1
                	ssh $remote_gene "ifconfig ${gene_eths[$i]} 0"
                	ssh $remote_sut "ifconfig ${sut_eths[$j]} 0"
			let ip_3rd++
			break
		fi

		let ip_3rd++
		ssh $remote_gene "ifconfig ${gene_eths[$i]} 0"
		ssh $remote_sut "ifconfig ${sut_eths[$j]} 0"
			
	
	done
done
fi





