#!/bin/sh

#show CPU info
# show what operation system
## show turbostat during busy and idle

prt() {
    printf "\033[1;42m$1\033[0m\n"
}
eprt() {
    printf "\033[1;45m$1\e[0m\n"
}
elog() {
    printf "\033[1;43m$1\e[0m\n"
}
#
dir_dpdk=""

# show cmdline info
echo ""
echo ""
echo ====================================================
echo ====================================================
echo "Platform Enabling Kit"
echo "version 0.1"
echo ====================================================
echo ====================================================
echo ""
echo ""


function check_pstate(){
    pstate_info=`dmesg | grep -i kernel | grep -i pstate`
    
    if [[ "$pstate_info" == "" ]]
    then
        printf "intel_pstate\tdisabled\n"
    else
        printf "intel_pstate\tenabled\n"
    fi
}

check_pstate

## show CPU base_freq
check_cpu_base_freq(){
    base_freq=$(lscpu | grep 'CPU MHz' | awk '{print $3}')
    printf "cpu base_freq(Mhz):\t$base_freq\n"   

}

function check_turbostat_installing(){

    echo `turbostat | grep -`
}

check_cpu_base_freq

## check if hyper threading
function check_hyper_threading_1(){
    hyper_thread=$(lscpu | grep Thread | awk '{print $4}')
    # echo $hyper_thread
    if [ $hyper_thread -lt 2 ]; then
        echo hyper_thread CLOSED
    else
        echo "hyper_thread OPENED"
        echo $(lscpu | grep Thread)
    fi
}



function check_hyper_threading_2(){

    echo ""
}

check_hyper_threading_1

# Memory Checking
# show more memory base info 

function show_mem_info() {
    mem_info=$(cat /proc/meminfo)
    echo "$mem_info"
}

function show_mem_size() {
    memsize=$(cat /proc/meminfo | grep -i memtotal | awk '{print "Memory Size:\t"$2" "$3}')
    echo "$memsize"
}

function show_mem_capacity() {
    memcapacity=$(dmidecode | grep -P 'Maximum\s+Capacity' | awk '{print "Memory Capacity:\t"$3 $4}')
    echo "$memcapacity"
}

## if numa's nodes count is greater than 1, then numa is opened.
function check_numa() {
    a=$(numactl --hardware | awk 'NR==1 {print $2}')
    if [ $a -lt 2 ]; then #if a < 2 , numa closes.
        prt "NUMA CLOSED"
    else
        prt "NUMA OPENED"
    fi
}

function show_mem_speed_DIMM() {
    tmp=$(dmidecode -t 17 | grep -E "^Handle|^Memory|^\sSize:|Locator" | grep -C 2 "^\sSize:\s[0-9]")
    echo "$tmp"
}

function show_dimm_population(){
    tmp=`dmidecode -t 4 | grep -i -E "socket|populated"`
    echo "$tmp"
}

#show_mem_info
show_mem_size
show_mem_capacity
#show_mem_speed_DIMM
show_dimm_population
check_numa

# check Network Card
function show_network_card_info() {
    network_card_info=`lspci | grep -i "net"`

    if [[ "$network_card_info" != "" ]]
    then
        echo "$network_card_info"
    else
        echo "network card in pcie not found"
    fi

}

function get_network_card_pcie() {
    if [[ "$(show_network_card_info)" != "network card not found" ]]
    then
        network_card_pcie=$(echo "$network_card_info" | awk '{print $1}')
        echo "$network_card_pcie"
    else
        echo "network card not found"
    fi
}

function show_nic_driver_firmware() {

    for net_driver_num in $(dmesg | grep 'renamed from' | awk 'NR > 1{print $5}'); do
        net_driver=${net_driver_num%?}
        output=$(ethtool -i "$net_driver" | grep -i -E "driver|version")

        echo "$net_driver"
        echo "$output"
    done
}

function check_ddp() {
    ddp_status=$(dmesg | grep -i ddp)
    if [[ "$ddp_status" == "" ]]; then
        elog "ddp NOT STATRED"
    else
        prt "$ddp_status"
    fi
}

show_network_card_info
#get_network_card_pcie
show_nic_driver_firmware
check_ddp



function check_iommu() {
    dmar_info=`dmesg | grep -i dmar`
    if [[ "$dmar_info" != "" ]]
    then
        if [ "$(dmesg | grep -i kernel | grep iommu=on)" == "" ]; then
            eprt "intel_iommu=off"
        else
            prt "intel_iommu=on"
        fi
    else 
        eprt "intel_iommu=off"
    fi
}


check_iommu


echo show lnksta ASPM
## show the network about the best

function check_lnksta(){
    for nic_pcie in $(lspci | grep -i Ethernet | awk '{print $1}'); do
        prt "nic_pcie is '$nic_pcie'"
        echo $(lspci -s "$nic_pcie" -vvv | grep Lnk)
    done
}

check_lnksta

# check the PCIe
echo ====================================================

# check QAT
echo ====================================================
echo checking QAT

## check the device is connected to the board
function check_qat_connection(){
    is_connected_to_board=$(lspci | grep Co-)

    if [ "$is_connected_to_board" == "" ]; then
        prt "QAT is NOT connected to the board !"
    else
        prt "QAT is connected to the board"
    fi
}

check_qat_connection


## check QAT driver  is opened
qat=$(lsmod | grep qat | awk '{print NR}' | tail -n1) # 统计行数，需要修改
if [ "$qat" == "" ]; then
    prt "QAT NOT INSTLLED"
elif [ $qat -ge 2 ]; then
    prt "QAT module INSTLLED"
    ## check the QAT server is started
    is_qat_started=$(service qat_service status)
    QAT_devices_counts=$(service qat_service status | grep -i There | awk '{print $3}')
    #echo $QAT_devices_counts
    if [ $QAT_devices_counts -eq 0 ]; then
        prt "NO QAT DEVICES IN THE SYSTEM"
    else
        prt "$is_qat_started"
    fi
else
    prt "QAT module UNINSTLLED"
fi

# check virtualization
prt "checking virtualization"

function check_dmar() {
    dmar_info=$(dmesg | grep -i dmar)
    if [[ "$dmar_info" == "" ]]
    then
        
    echo "$dmar_info"
    fi
}

check_dmar

# check SST-BF
echo ====================================================
echo checking SST-BF config
echo
#ls -F /sys

## first check the pstate enabling.
function show_sys_cpu0_max_freq(){
    pstate_info=`dmesg | grep -i kernel | grep -i pstate=disable`
    if [[ "$pstate_info" == "" ]]
    then 
        sys_cpu0_max_freq=$(cat /sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_max_freq)
        prt "cpu max freq:\t$sys_cpu0_max_freq"
    else
        echo "pstate=disable. No cpu_max_freq."
    fi
}

function show_sys_cpu0_min_freq(){
    pstate_info=`dmesg | grep -i kernel | grep -i pstate=disable`
    if [[ "$pstate_info" == "" ]]
    then 
        sys_cpu0_min_freq=$(cat /sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_min_freq)
        prt "cpu min freq:\t$sys_cpu0_min_freq"
    else 
        echo "pstate=disable. No cpu_min_freq."
    fi
}


show_sys_cpu0_max_freq
show_sys_cpu0_min_freq


## check RDT
echo ====================================================
echo RDT base Cap
function check_rdt(){
    tmp=`pqos -d`

    if [[ "$tmp" == "" ]]
    then 
        echo "RDT disable"
    else 
        echo "$tmp"
        fi
}

check_rdt

echo ====================================================
echo checking DPDK support
echo hugepage info


mount | grep huge
function check_hugepage(){
    tmp=$(cat /proc/meminfo | grep HugePages_Total | awk '{print $2}')
    if [ $tmp -gt 0 ]; then
        prt "HugePages OPENED"

        #if
    else
        prt "HugePages CLOSED, DPDK NOT SUPPORTED !"
    fi
}



echo 'checking DPDK device-net'
## check hugepage

# cat /sys/class/net/ens801f0/device/uevent


function show_log(){
    lscpu_info=`lscpu`
    cmdline_info=`cat /proc/cmdline`
    hugepage_info=`cat /proc/meminfo | grep Huge`

    echo "$lscpu_info"
    echo "$cmdline_info"
    echo "$hugepage_info"

}

echo "$(show_log)" > smoketest.log