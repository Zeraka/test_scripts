#!/bin/python3
"""
Basic lib about automation
"""
import subprocess
import os

# batch rum shell
def runcmdlist(cmdlist):
    output=subprocess.Popen("",shell=True,stdin=subprocess.PIPE)

    for cmd in cmdlist:
        temp = subprocess.Popen(cmd, shell=True, stdin=output.stdout,stdout=subprocess.PIPE,stderr=subprocess.STDOUT)
        output=temp
    ret=output.stdout.read().decode('utf-8')
    ret=ret[:-1]
    retcode=output.returncode
    
    return ret,retcode


def runcmd(cmd,logprt=True):

    cmdlist=cmd.split("|")
    ret,retcode=runcmdlist(cmdlist)
    if logprt==True:
        if len(ret)==0:
            print("execute \""+cmd+"\"\t\texecution success!")
        else:
            #print("Result Print:")

            print(ret)
    
    return ret,retcode



def modprobe_vfio():
    runcmd("modprobe vfio")
    runcmd("modprobe vfio-pci")  

if __name__=="__main__":

    pass
