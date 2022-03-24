# jupyter_remote
## Spawn a Jupyter Lab on a remote server and connect to with SSH port forwarding/tunneling it with your local computer.

It is developed and tested on a Mac air laptop running Mac OS Monterey (version 12.2.1).


The script [jupyter_remote_connect.sh](jupyter_remote_connect.sh) will spawn a remote Jupyter Lab and connect it to your local browser using SSH.
The script is adopted from https://stackoverflow.com/questions/43696291/script-to-run-jupyter-notebooks-from-remote-server

The script assumes that you are using conda on the remote server. It also uses a screen session, so screen must also be installed.

## Prerequisites:
- Conda must be installed on the remote server, and there must be an environment with jupyterlab included.
- Screen is needed on the remote server to spawn the Jupyter Lab in a screen session.
- A web browser on the local machine. I have tested it with Chrome and Firefox.
- SSH is needed.

## Instructions:
- Edit the variables in Section. 1 on top. NO SPACES around the equals signs!
  - Edit the server log in information (username and serverIP. DNS domain name should work instead of the IP address).
  - Specify the directory you want to work in on the server (work_dir).
  - Specify the conda environment name or directory.
  - Indicate which browser to use on the LOCAL computer. It must work with "open -a" on the command line.
  - Specify the ports to use on the local and remote machines. They can be the same. Try not to use a port already being used, especially on the remote server.
- Make the script executable, if it is not already. In a terminal, use `chmod +x jupyter_remote_connect.sh`.
- To run the script, invoke `./jupyter_remote_connect.sh`.
- Shutting down (highly recommended)
  - These instructions are printed out to the screen when you run the script.  
  - The easiest way to shut down the Jupyter Lab server and screen session is to use the "File --> Shut Down" menu in the web browser.
  - The tedious way to shut it down on the remote server is to SSH in to the remote server, use the `screen -r` command to attach to the screen session, then `Ctrl-C` to kill the Jupyter Lab.
  - To shut down the SSH port forwarding/tunnel connection:
    - Do this on your LOCAL computer
    - `ps -u your_local_user_name | grep SSH`
    - Look for a line with port forwarding, e.g. **-L 8890:localhost:8888 -N**.
    - Kill the process with `kill pid` where pid is the *second* number in the output from above.
