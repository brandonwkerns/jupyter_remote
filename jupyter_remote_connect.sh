#!/bin/bash

# This script will spawn a remote Jupyter Lab and connect it to your local browser using SSH.
# The script is adopted from https://stackoverflow.com/questions/43696291/script-to-run-jupyter-notebooks-from-remote-server

## 1. SET VARIABLES TO ESTABLISH THE SSH CONNECTION
## !!! IMPORTANT: No spaces around the equals signs !!!

## Log in information
username=bkerns
serverIP=orca.atmos.washington.edu  #the name or IP address of the server

## Specify directory ON THE SERVER where your notebook files, ect. will be.
## If this is an existing directory, you will see your files!
## If not, the directory will be created.
# work_dir=/home/orca/data/in_situ/NCEP_stageIV_QPE/examples/read_and_plot_using_iris
work_dir=/home/orca/bkerns

## Specify directory or name of Python environment ON THE SERVER.
conda_env=/home/orca/data/in_situ/NCEP_stageIV_QPE/examples/read_and_plot_using_iris/env
# conda_env=meteo

## Which web browser? (Must work with "open -a" command on Mac)
browser="Google Chrome"
# browser="Firefox"

# Other variables to establish the ssh connection
localPort=8890
remotePort=8888

########################################################################################################
########### You should not need to edit below here. ####################################################
########################################################################################################

local_user=`whoami`  # User name on your local computer.

# 2. RUN JUPYTER IN REMOTE SERVER
out=$(ssh -T ${username}@${serverIP} <<HERE
    # Only run jupyter if it isn't already running in screen session
    if [[ \$(screen -ls | grep jupyter | wc -l) -lt 1 ]]
    then
        echo "--> Starting new Jupyter Lab session in screen terminal:"

        # Get into work_dir if it exists. Create it if necessary.
        mkdir -p $work_dir
        cd $work_dir

        # Create a script to run jupyter
        echo '#!/bin/sh' > jupyter.sh
        echo "source /home/disk/orca/bkerns/anaconda3/bin/activate $conda_env" >> jupyter.sh
        echo "jupyter notebook --no-browser --port=${remotePort} --NotebookApp.token=${username}" >> jupyter.sh
        # Run jupyter in the background
        screen -S jupyter -d -m /bin/bash ./jupyter.sh
    else
        echo "--> Using existing instance of Jupyter Lab in screen terminal."
    fi

    screen -ls
HERE
)

echo $out
echo ''
echo 'To end the Jupyter Lab server and close the screen session on the remote machine,'
echo 'Use the "File --> Shut Down" menu in your web browser.'
echo 'OR alternately, log on the the server, use "screen -r" to get into the screen session, then Ctrl-C to kill Jupyter.'
echo ''

# 3. SET SSH TUNNEL
# Start listening in local port 8890 if that port isn't already in use

num=`ps -u ${local_user} | grep ssh | grep ${localPort} | wc -l`
if [[ $num -eq 0 ]]
then
    echo 'Establishing SSH tunnel connection:'
    ssh -f ${username}@${serverIP} -L ${localPort}:localhost:${remotePort} -N
else
    echo 'SSH tunnel connection already established. I will use the existing one:'
fi
echo `ps -u ${local_user} | grep ssh | grep ${localPort}`
echo ''
echo "To kill the SSH tunnel, use: kill "`ps -u ${local_user} | grep ssh | grep ${localPort} | awk '{print $2}'`
echo "And to verify it stopped running: ps -u ${local_user} | grep ssh | grep ${localPort}"
echo "(Should give no output)"

#
# Open jupyter in browser
open -a "${browser}" http://localhost:${localPort}/lab?token=${username} &
