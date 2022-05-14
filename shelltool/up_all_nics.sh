#!/bin/bash

eths=$(ifconfig -a | awk '{print $1}' | awk /:/| sed 's/.$//g')
#echo $eths
eths_num=$(echo $eths| awk '{print NF}')
for((i=1;i<=$eths_num;i++))
do
        eth_name=$(echo "$eths" | awk -v j=$i '{print $j}') #j=$i一定要与'{}'有间隔，否则会报错
        #echo $eth_name
	    ifconfig "$eth_name" up
        echo "$eth_name has been up"
done