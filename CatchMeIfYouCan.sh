#!/bin/bash

# TEXT STYLE
# Reset
NC='\033[0m'       # Text Reset

# Regular Colors
Black='\033[0;30m'        # Black
Red='\033[0;31m'          # Red
Green='\033[0;32m'        # Green
Yellow='\033[0;33m'       # Yellow
Blue='\033[0;34m'         # Blue
Purple='\033[0;35m'       # Purple
Cyan='\033[0;36m'         # Cyan
White='\033[0;37m'        # White

# Bold
BBlack='\033[1;30m'       # Black
BRed='\033[1;31m'         # Red
BGreen='\033[1;32m'       # Green
BYellow='\033[1;33m'      # Yellow
BBlue='\033[1;34m'        # Blue
BPurple='\033[1;35m'      # Purple
BCyan='\033[1;36m'        # Cyan
BWhite='\033[1;37m'       # White

# default mode
mode="proxy"
# Set the default rotation interval (in seconds)
interval=60
# default timeout before skipping proxy when running tests (in seconds)
timeout=10
# default rotation mode 
rotation="random"
# default vpn client
client="protonvpn-cli"
# Banner 
echo -e "${BPurple}                ____ __  __ _____   ______ ";
echo "               / ___|  \/  |_ _\ \ / / ___|";
echo "              | |   | |\/| || | \ V / |    ";
echo "              | |___| |  | || |  | || |___ ";
echo "               \____|_|  |_|___| |_| \____|";
echo "";
echo "                    Catch Me If You Can               ";
echo -e "${Purple}               Tool developed by QuetzalCtrl";
echo "               https://github.com/QuetzalCtrl";
echo -e "${BWhite}";
echo "Catch Me If You Can is a tool that performs automated IP rotation using proxies or VPNs."
echo "Important : As this script uses system-wide configurations, you may need root privileges."
# echo ""
# echo "VPNs are a more secure and reliable option for IP rotating, but they may not be suitable for all use cases."
# echo "Proxies are a simpler and faster option, but they may not provide as much anonymity or security."
echo ""
echo -e "${BBlue}================================================================================"
echo -e "${White}"

# Parse command line options
while getopts ":m:i:t:hp:c:" opt; do
  case $opt in
    m) if [[ "$OPTARG" = "vpn" ]] || [[ "$OPTARG" = "proxy" ]]; then 
        mode="$OPTARG"
      else 
        echo "$OPTARG: Incorrect value for the -m option. Valid options : vpn proxy" >&2; exit 1
      fi ;;
    i) interval="$OPTARG";;
    t) timeout="$OPTARG" ;;
    p) proxy_list="$OPTARG" ;;
    c) client="$OPTARG" ;;
    r) rotation="$OPTARG" ;;
    h)
      echo -e "${BWhite}Usage:${White} $0 [-m mode] [-i interval] [-h]"
      echo ""
      echo -e "${BWhite}Optional arguments:${White}"
      echo "      -m mode     : IP Rotation mode (proxy | vpn)"
      echo "         Default  : proxy"
      echo "      -i interval : Interval (in seconds) between every new connexion"
      echo "         Default  : 60";
      echo "      -h help     : Display help message"
      echo "      -r rotation : Rotation mode (random | sequential)"
      echo "         Default  : random"
      echo ""
      echo -e "${BWhite}Proxy mode arguments:${White}"
      echo "      -p proxies  : The list of proxies (path to file)"
      echo "      -t timeout  : Delay (in seconds) before skipping proxy if no reply"
      echo "         Default  : 10"
      echo "      -x protocol : Proxy protocol (http-only | https-only | http-https)"
      echo "         Default  : http-https"

      echo ""
      echo -e "${BWhite}VPN mode arguments:${White}"
      echo "      -c client   : VPN Client (protonvpn-cli | cyberghostvpn | windscribe-cli)"
      echo "         Default  : protonvpn-cli"
      echo ""
      echo -e "${BWhite}Examples:${White}"
      echo "      $0 -m vpn -i 100"
      echo "      $0 -m proxy -p /path/to/my_proxies_list.txt -r sequencial"
      echo "      $0 -m vpn -c windscribe-cli -r random"
      exit 0
      ;;
    \?) echo "Invalid option: -$OPTARG" >&2; exit 1 ;;
    :) echo "Option -$OPTARG requires an argument." >&2; exit 1 ;;
  esac
done

echo -e "${BWhite}Starting IP Rotation in $mode mode"
echo -e "${White}Interval between each rotation is set to $interval seconds"
if [[ "$mode" = "proxy" ]];then 
  echo "Timeout : skipping a proxy after $timeout seconds if no reply"
else
  echo "VPN Client : OpenVPN"
  echo "Rotation mode : random"
fi

echo ""
echo -e "${BBlue}================================================================================"
echo -e "${White}"

if [[ "$mode" = "proxy" ]];then 
  
  # Reset the system-wide proxy configuration before exiting the script,
  # in case anything goes wrong
  set -e
  cleanup() {
    echo -e "${BPurple}\n\nProxy configuration reset"
    gsettings set org.gnome.system.proxy mode 'none'
  }
  trap cleanup EXIT

  # Now that we know we're in proxy mode, we can check the submitted proxy list
  if [[ -z "${proxy_list}" ]];then 
    echo -e "${BRed}No proxies specified"
    echo -e "${White}When using the proxy rotation mode, please specify a list of proxies with the option -p"
    echo "E.g. '$0 -m proxy -p ~/proxies.txt'"
    exit 1
  elif ! [[ -f "${proxy_list}" ]];then 
    echo -e "${BRed}List of proxies not valid"
    echo -e "${White}When specifying a list of proxies with the option -p, please make sure it's a valid file"
    echo "E.g. '$0 -m proxy -p ~/proxies.txt'"
    exit 1
  fi
  # Read the list of proxies from the file
  echo "Reading proxies file list ${proxy_list}"
  proxies=()
  while IFS= read -r line; do
    proxies+=("$line")
  done < "$proxy_list"

  # Initial proxy index (-1 because the increment is made at the beginning of the loop)
  current_index=-1
  # We don't want to wait $interval seconds for the first iteration
  skipped=1

  # Rotate the proxy every interval seconds
  while :
  do
    # wait for the interval only if precedent connection is successful (so when skipped = 0)
    [[ "$skipped" -eq 0 ]] && sleep $interval 
    # Rotate to the next proxy
    current_index=$(( (current_index + 1) % ${#proxies[@]} ))
    http_proxy=${proxies[current_index]}
    https_proxy=${proxies[current_index]}
    echo -e "${BWhite}Connecting to ${proxies[current_index]}..."


    # Set the system-wide proxy configuration if both HTTP and HTTPS connectivities are successful
    if [[ "$(curl -s --connect-timeout $timeout -w "%{http_code}" -x "$http_proxy" "http://www.example.com" -o /dev/null)" -eq 200 ]] && 
      [[ "$(curl -s --connect-timeout $timeout -w "%{http_code}" -x "$https_proxy" "https://www.example.com" -o /dev/null)" -eq 200 ]]; then
      gsettings set org.gnome.system.proxy mode 'manual'
      gsettings set org.gnome.system.proxy.http host "${http_proxy%:*}"
      gsettings set org.gnome.system.proxy.http port "${http_proxy##*:}"
      gsettings set org.gnome.system.proxy.https host "${https_proxy%:*}"
      gsettings set org.gnome.system.proxy.https port "${https_proxy##*:}"
      echo -e "${BGreen}Connected to the proxy $http_proxy"
      skipped=0
    else
      echo -e "${BRed}Skipping $http_proxy (connect-timeout)"
      skipped=1
    fi
  done

elif [[ "$mode" = "vpn" ]]; then
  # PROTON VPN
  if [[ "$client" = "protonvpn-cli" ]]; then
    # Reset the vpn configuration before exiting the script,
    # in case anything goes wrong
    set -e
    cleanup() {
      protonvpn-cli d
    }
    trap cleanup EXIT
    
    while :
    do
      echo -e "${BWhite}protonvpn-cli says :${White}"
      protonvpn-cli c -r
      if ! [[ $? -eq 0 ]]; then
        echo -e "${BRed}An error occured, please make sure you have protonvpn-cli installed,"
        echo "and that you are currently logged in."
        break
      fi
      echo -e "${BGreen}Connected to the VPN server"
      echo -e "${BWhite}Server informations${White}"
      protonvpn-cli s | grep -E 'IP:|Server:|Country:'
      sleep $interval
      echo -e "${BWhite}Changing VPN Server...${White}"
    done
  # WINDSCRIBE VPN 
  elif [[ "$client" = "windscribe-cli" ]]; then
    # Reset the vpn configuration before exiting the script,
    # in case anything goes wrong
    set -e
    cleanup() {
      windscribe-cli disconnect
    }
    trap cleanup EXIT

    # Available countries 
    codeList=( "FR" "CA" "TR" "US" "DE" "NL" "CH" "NO" "GB" "HK" "RO" )

    while :
    do
      # Random rotation mode
      countryCode=$(echo "${codeList[RANDOM % ${#codeList[@]} ]}")
      echo -e "${BWhite}windscribe-cli says :${White}"
      windscribe-cli connect "$countryCode"
      if ! [[ $? -eq 0 ]]; then
        echo -e "${BRed}An error occured, please make sure you have windscribe-cli installed,"
        echo "and that you are currently logged in."
        break
      fi
      echo -e "${BGreen}Connected to the VPN server"
      # Waiting for the connection is really up before doing the curl
      echo -e "${BWhite}Server informations${White}"
      ip=$(LANG=c ip a show tun0 2>/dev/null| grep "inet " | awk '{print $2}' | awk -F/ '{print $1}')
      # Display the IP address only if the ip a command was successful 
      # (it's mainly to make sure everything still works even if tun0 is not the good interface,
      # in that case, the only downside would be no IP address is shown in the server infos, but everything will still work)
      [[ "$ip" = "" ]] || echo "IP      : $ip"
      echo "Country : $countryCode"
      sleep $interval
      echo -e "${BWhite}Changing VPN Server...${White}"
    done
  elif [[ "$client" = "cyberghostvpn" ]]; then
    echo -e "${BRed}cyberghostvpn: This VPN client is not available yet"
    exit 1
  else
    echo -e "${BRed}VPN client not valid"
    echo -e "${BWhite}Supported clients: ${White}}protonvpn-cli cyberghostvpn windscribe-cli"
    echo "E.g. '$0 -m vpn -c cyberghostvpn'"
  fi
fi
