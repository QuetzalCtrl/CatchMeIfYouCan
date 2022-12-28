# CatchMeIfYouCan

Catch Me If You Can is a tool that allows for automated IP rotation using proxies or VPNs on Linux systems.

## System Requirements

This tool is only available for Linux systems.

## Installation

To install this tool from the git repository, follow these steps:

- Clone the repository to your local machine:

  ```git clone https://github.com/QuetzalCtrl/CatchMeIfYouCan.git```

- Navigate to the directory where the repository was cloned:

  `cd CatchMeIfYouCan`

- Install the tool using the installation script:

  `chmod +x install.sh && ./install.sh`

## Usage

To use this tool, run the following command:

`ifucan [options]`

### Options

```
      -m mode     : IP Rotation mode (proxy | vpn)
         Default  : proxy
      -i interval : Interval (in seconds) between every new connexion
         Default  : 60
      -h help     : Display help message
      -r rotation : Rotation mode (random | sequential)
         Default  : random
 ```

### Examples

To rotate your IP using a proxy every 60 seconds:

`ip-rotation -p -i 60`

To rotate your IP using a VPN every 30 seconds:

`ip-rotation -v -i 30`
