
# Automated Setup Script for Ubuntu 20.04, Nginx, Pm2, and Node.js Application Deployment
This script is designed to simplify the process of setting up a new Virtual Private Server (VPS) running Ubuntu 20.04 for deploying Node.js applications. It eliminates the need to manually follow multiple guides and troubleshoot issues that arise during the setup.

## Purpose
The motivation behind developing this script was the repetitive nature of rebuilding the server and the time-consuming task of ensuring everything was properly configured. By automating the process, it significantly reduces the time and effort required to secure the server with a user account, obtain SSL certificates, install NGINX, set up PM2, and deploy the initial server block with minimal user input.

## Usage
To use the script, follow these steps:

1. Start with a fresh installation of Ubuntu 20.04 on your VPS.
2. Clone this repository to your local machine or directly download the script file, or copy/paste the contents into a file called `setup.sh`
	1.  `nano ./setup.sh`
	2. paste the contents into the file (right click in most cases)
	3. `ctrl + x` to exit, `y` to agree saving changes, `enter` to save as the same filename
3. (Optional) Make the script executable by running the command `chmod +x setup.sh`.
4. Run the script `./setup.sh` if you've made it an executable, or run it via bash `bash ./setup.sh` if you havent
5. Follow the prompts and provide the necessary information when prompted.
6. Sit back and let the script automate the installation and setup process.


Please note that the script assumes a basic familiarity with server administration and Node.js application deployment. It's essential to review the script and ensure it aligns with your specific requirements before running it.

## Contributions
Contributions to this script are welcome. If you encounter any issues or have suggestions for improvements, please open an issue or submit a pull request on the GitHub repository.

## Disclaimer
Please be aware that while this script aims to automate the server setup process, it's always recommended to review the changes made by the script and ensure they align with your security and deployment requirements. The script comes with no warranties or guarantees, and the user assumes all responsibility for its usage.

## License
This script is licensed under the MIT License. Please refer to the LICENSE file for more details.