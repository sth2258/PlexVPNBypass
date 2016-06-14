echo
echo 
echo "VPN ByPass for Plex Media Server"
echo "by sth2258 (ported from XFlak)"
echo "v1.0 14-June-2016"
echo 
echo

#Initialize some variables used throughout
DEBUG=false
currentPlexIP=currentPlexIP.txt     # File used to store the current IP's for plex.tv
storedPlexIP=storedPlexIP.txt       # File used to store the Plex IP's that are actually written to the routing table

#Begin by getting the default gateway
defaultGateway=`route -n get default|grep -i gateway:|awk '{print $2}'`

#Get the current list of Plex IPs
dig +short plex.tv  > $currentPlexIP
#echo "None" > $currentPlexIP
if [ ! -f $currentPlexIP ];
then
   echo "ERROR: File with current Plex IP's was not created. Is dig installed? Do you have write permissions to the directory where the file is being written to? Error 53."
fi

#Compare the current list to the previous ones added to the routing table
if [ ! -f $storedPlexIP ];
then
    echo "WARN: No existing IP file found. Assuming first execution."

    tmp=0;
    while read line; do
        echo "INFO: Adding $line to routing table."
        commandToExecute="sudo route -n add $line $defaultGateway 255.255.255.255"
        $commandToExecute
        let tmp+=1
    done <$currentPlexIP

else
    # Read and store the existing entiries into an array
    tmp=0;
    while read line; do
        old[$tmp]=$line
        let tmp+=1
    done <$storedPlexIP
    
    # Read and store the new values inside an array
    tmp=0;
    while read line; do
        new[$tmp]=$line
        let tmp+=1
    done <$currentPlexIP
    
    for i in "${old[@]}"
    do
        for n in "${new[@]}"
        do
            if [ "$x" == "valid" ]; then
                echo "x has the value 'valid'"
            fi
        done
    done
    # Find out which entries are removals
    actionsPerformed=0
    for removalTarget in `grep -Fxv -f currentPlexIP.txt storedPlexIP.txt`; 
    do
        echo "INFO: Issue removal for $removalTarget"
        commandToExecute="sudo route -n delete $removalTarget $defaultGateway 255.255.255.255"
        $commandToExecute
        actionsPerformed+=1
    done

    # Find out which entires are additions
    for additionTarget in `grep -Fxv -f storedPlexIP.txt currentPlexIP.txt`;
    do
        echo "INFO: Issue new entry for $additionTarget"
        commandToExecute="sudo route -n add $additionTarget $defaultGateway 255.255.255.255"
        $commandToExecute
        actionsPerformed+=1
    done

    if [ $actionsPerformed -eq 0 ]
    then
        echo "INFO: No changes necessary."
    fi

    

fi

# Finally, make the lastest update the master
cp $currentPlexIP $storedPlexIP
rm $currentPlexIP

echo