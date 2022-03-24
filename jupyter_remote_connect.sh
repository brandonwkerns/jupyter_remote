#######################################################################
## 1. SET VARIABLES TO STABLISH THE SSH CONNECTION
# Get username from command line: bash jupyter.sh -u username
while [[ $# -gt 1 ]]
do
key="$1"
case $key in
    -u|--username)
    username="$2"
    shift # past argument
    ;;
esac
shift # past argument or value
done
# Specificy other variables to stablish the ssh connection
localPort=8890
browser="Google Chrome"
serverIP=the_IP_of_the_server
#######################################################################
# 2. RUN JUPYTER IN REMOTE SERVER
out=$(ssh -T ${username}@${serverIP} <<HERE
    # Only run jupyter if it isn't already running
    if [ \$(ps -u ${username} | grep jupyter | wc -l) -eq 0 ]
    then
        # Create a folder called jupyter, and move into it
        if [ ! -d jupyter ]; then mkdir jupyter; fi
        cd jupyter
        # Create a script to run jupyter
        echo "jupyter notebook --no-browser --NotebookApp.token=${username}" > jupyter.sh 
        # Run jupyter in the background
        screen -S jupyter -d -m bash jupyter.sh
    fi
    # Output the remote port number. If there is more than 1, get the first one
    jupyter notebook list | grep localhost | awk '{split(\$0,a,"localhost:");split(a[2],b,"/"); print b[1]}' | head -n1
HERE
)

#######################################################################
# 3. SET SSH TUNNEL
# Pass the remote port to a variable in the local machine
remotePort=$(echo $out | awk '{print $NF}') 
# Start listening in local port 8890 if that port isn't already in use
# num equal 1 if port number is already in use, 0 otherwise
num=$(netstat -lnt | awk 'BEGIN{x=0} ($6 == "LISTEN" && $4 ~ "8890$"){x=1}END{print x}')
if [ $num -eq 0 ]
then
    ssh -f ${username}@${serverIP} -L ${localPort}:localhost:${remotePort} -N
fi
#
# Open jupyter in browser
open -a "${browser}" http://localhost:${localPort}/tree?token=${username} &
