#!/bin/bash
#Script to reduce fan speeds on ilo4 remotely.
# Install new public key on ilo4 as described here:
# https://ouphe.net/2020/04/05/add-ssh-key-to-ilo4-user-for-authentication/
#HELPFUL INFO
# Use Putty or similar to login from Windows. Reset iLO (iLO > Info > Diagnostics) each time to view. Only first login can see any responses.
# Run "fan info" to get readout





ILO4=MYIP
ILOUSER=ilofanuser
PASSWORD='MYPASSWORD'
PCILO=1000
PCIHI=5000
HDCLO=500
HDCHI=4000
MISCLO=500
MISCHI=3000
HDMAXLO=100
HDMAXHI=250
HDNOAUTHTEMPCAUT=65
HDNOAUTHTEMPCRIT=70





#PCI
# Set minima
for PID in 24 25 26 27 28 29 30 31 32 37 38 39 40 41 42 43 44 45 47 48 49 50 51 52 53 54 55 56 57 58 59 60 61
do
        sshpass -p $PASSWORD ssh $ILOUSER@$ILO4 -o KexAlgorithms=+diffie-hellman-group14-sha1 -o HostKeyAlgorithms=ssh-rsa -o HostKeyAlgorithms=ssh-dss -o HostKeyAlgorithms=ssh-rsa -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null "fan pid $PID lo $PCILO"
done

# Set maxima
for PID in 24 25 26 27 28 29 30 31 32 37 38 39 40 41 42 43 44 45 47 48 49 50 51 52 53 54 55 56 57 58 59 60 61
do
        sshpass -p $PASSWORD ssh $ILOUSER@$ILO4 -o KexAlgorithms=+diffie-hellman-group14-sha1 -o HostKeyAlgorithms=ssh-rsa -o HostKeyAlgorithms=ssh-dss -o HostKeyAlgorithms=ssh-rsa -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null "fan pid $PID hi $PCIHI"
done





#HD Controller Systems
# Set minima
for PID in 19 20 21 22 23
do
        sshpass -p $PASSWORD ssh $ILOUSER@$ILO4 -o KexAlgorithms=+diffie-hellman-group14-sha1 -o HostKeyAlgorithms=ssh-rsa -o HostKeyAlgorithms=ssh-dss -o HostKeyAlgorithms=ssh-rsa -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null "fan pid $PID lo $HDCLO"
done

# Set maxima
for PID in 19 20 21 22 23
do
        sshpass -p $PASSWORD ssh $ILOUSER@$ILO4 -o KexAlgorithms=+diffie-hellman-group14-sha1 -o HostKeyAlgorithms=ssh-rsa -o HostKeyAlgorithms=ssh-dss -o HostKeyAlgorithms=ssh-rsa -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null "fan pid $PID hi $HDCHI"
done





#MISC - Chipset, iLO Chips, Exhaust and Intake, OCSD
# Set minima
for PID in 33 34 35 36 46 62 63 64 65
do
        sshpass -p $PASSWORD ssh $ILOUSER@$ILO4 -o KexAlgorithms=+diffie-hellman-group14-sha1 -o HostKeyAlgorithms=ssh-rsa -o HostKeyAlgorithms=ssh-dss -o HostKeyAlgorithms=ssh-rsa -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null "fan pid $PID lo $MISCLO"
done



# Set maxima
for PID in 33 34 35 36 46 62 63 64 65
do
        sshpass -p $PASSWORD ssh $ILOUSER@$ILO4 -o KexAlgorithms=+diffie-hellman-group14-sha1 -o HostKeyAlgorithms=ssh-rsa -o HostKeyAlgorithms=ssh-dss -o HostKeyAlgorithms=ssh-rsa -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null "fan pid $PID hi $MISCHI"
done





#Special - HD Max
# Set minima
for PID in 07
do
        sshpass -p $PASSWORD ssh $ILOUSER@$ILO4 -o KexAlgorithms=+diffie-hellman-group14-sha1 -o HostKeyAlgorithms=ssh-rsa -o HostKeyAlgorithms=ssh-dss -o HostKeyAlgorithms=ssh-rsa -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null "fan pid $PID lo $HDMAXLO"
done

# Set maxima
for PID in 07
do
        sshpass -p $PASSWORD ssh $ILOUSER@$ILO4 -o KexAlgorithms=+diffie-hellman-group14-sha1 -o HostKeyAlgorithms=ssh-rsa -o HostKeyAlgorithms=ssh-dss -o HostKeyAlgorithms=ssh-rsa -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null "fan pid $PID hi $HDMAXHI"
done




#Override Thresholds due to unauthenticated drives
# Set caution
#for PID in 07
#do
#        sshpass -p $PASSWORD ssh $ILOUSER@$ILO4 -o KexAlgorithms=+diffie-hellman-group14-sha1 -o HostKeyAlgorithms=ssh-rsa -o HostKeyAlgorithms=ssh-dss -o HostKeyAlgorithms=ssh-rsa -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null "fan t $PID caut $HDNOAUTHTEMPCAUT"
#done

# Set critical
#for PID in 07
#do
#        sshpass -p $PASSWORD ssh $ILOUSER@$ILO4 -o KexAlgorithms=+diffie-hellman-group14-sha1 -o HostKeyAlgorithms=ssh-rsa -o HostKeyAlgorithms=ssh-dss -o HostKeyAlgorithms=ssh-rsa -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null "fan t $PID crit $HDNOAUTHTEMPCRIT"
#done
