#!/bin/bash

eths=$(ifconfig -a | awk !/lo/'{print $1}'|awk !/br/ | awk /:/| sed 's/.$//g')
eths_num=$(echo $eths| awk '{print NF}')
eth_macs=$(ifconfig -a | grep ether | awk '{print $2}')
for((i=1;i<=$eths_num;i++))
do
        eth_bus=$(ethtool -i $(echo $eths | awk -v j=$i '{print $j}') | grep "bus-info:" | awk '{print $2}')
        eth_linked=$(ethtool $(echo $eths | awk -v j=$i '{print $j}') | grep 'Link detected')
        eth_name=$(echo $eths | awk -v j=$i '{print $j}')
        eth_mac=$(echo $eth_macs | awk -v j=$i '{print $j}')
        echo $eth_bus   $eth_linked   $eth_name   $eth_mac
done
