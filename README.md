# Catch Me If You Can (ifucan)

Catch Me If You Can (or ifucan) is a tool that performs automated IP rotation using proxies or VPNs on Linux systems.

![ifucan](https://user-images.githubusercontent.com/58345798/210527533-c440dde1-c891-452a-a518-b874c8abd124.png)

## Requirements

- This tool is only available for Linux systems

- When using the VPN rotation mode, please make sure you have already installed the selected VPN client on your system, and that you are logged in.

- When using the Proxy rotation mode, you have to specify a lists of proxies to use, this tool does not provide proxies server to connect to. You can find an example of the correct syntax to follow for this file file on this repo, the file is named `proxy_list_example.txt`.

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

`ifucan [-h] [-m mode] [-i interval] [-r rotation]`

![ifucan](https://user-images.githubusercontent.com/58345798/210527642-79f0a6f6-2f69-40f7-9cce-f308d71935cb.gif)

### Options

#### Optional arguments
```
      -h help     : Display help message
      -m mode     : IP Rotation mode (proxy | vpn)
         Default  : proxy
      -i interval : Interval (in seconds) between every new connexion
         Default  : 60
      -r rotation : Rotation mode (random | sequential)
         Default  : random
 ```

 #### Proxy mode arguments
```
      -p proxies  : The list of proxies (path to file)
      -t timeout  : Delay (in seconds) before skipping proxy if no reply
         Default  : 10
      -x protocol : Proxy protocol (http-only | https-only | http-https)
         Default  : http-https
 ```

 #### VPN mode arguments
```
      -c client   : VPN Client (protonvpn-cli | cyberghostvpn | windscribe-cli)
         Default  : protonvpn-cli
      -f filter   : Connect only to the country given (By country-code, separated by a comma if multiple)
         Default  : ALL
      -l list     : List the available countries for a specific VPN
 ```

### Examples

#### Proxy mode examples

This command will rotate your IP using proxies (`-m`) listed in `my_proxies_list.txt` (specified with `-p`). It will connect to each proxy written in the file, line by line (`-r sequential`). If a proxy doesn't reply, it will skip to the next one after 10 seconds (default connection timeout value, modify it using `-t`).

`ifucan -m proxy -p my_proxies_list.txt -r sequential`

This command will rotate your IP using proxies listed in `my_proxies_list.txt`, using only https (`-x`). As the rotation mode is not specified here (`-r`), it will connect to a random proxy listed in the `my_proxies_list.txt` file, and connect to the next one every 10 seconds (`-i`). If a proxy doesn't reply, it will skip to the next one after 5 seconds (`-t`).

`ifucan -m proxy -p my_proxies_list.txt -x https-only -i 10 -t 5`

#### VPN mode examples

This command will list (`-l`) all the countries available on cyberghostvpn. You can then use `-f` to limit your VPN connection to certain countries only.

`ifucan -m vpn -c cyberghostvpn -l`

This command will rotate your IP using protonvpn-cli's VPNs (as the `-c` argument is not specified).
It will connect to only French and American servers (`-f`), and since the rotation mode (`-r`) is set to sequential, it will first connect to a french server, then to an american one, and back to a french one, and so on.

`ifucan -m vpn -f FR,US -r sequential`

This command will rotate your IP using windscribe-cli's VPNs (`-c`) every 30 seconds (`-i`). You can then use `-f` to limit your VPN connection to certain countries only.

`ifucan -m vpn -c windscribe-cli -i 30`

