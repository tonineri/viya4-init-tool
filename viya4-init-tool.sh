#!/bin/bash

# -------------------------------------------------  header  --------------------------------------------------

# SAS Viya 4 Initializaton Tool
# Description: the script can fully prepare a bastion host for a SAS Viya 4 cluster creation and management on Azure, AWS and Google Cloud Plaform.

# Copyright © 2023, SAS Institute Inc., Cary, NC, USA. All Rights Reserved.
# SPDX-License-Identifier: Apache-2.0

# -------------------------------------------------  options  -------------------------------------------------

V4ITVER="v1.0.1"        # viya4-init-tool version
LSVIYASTABLE="2023.06"  # latest SAS Viya Stable supported version by tool
LSVIYALTS="2023.03"     # latest SAS Viya LTS supported version by tool

if [ "$1" == "--version" ]; then
    echo ""
    echo "SAS Viya 4 Initialization Tool"
    echo "  $V4ITVER | June 23rd, 2023"
    echo ""
    exit 0
elif [ "$1" == "--whitelist" ]; then
    urls=$(grep -oE 'https?://[^/"]+' "$0" | awk -F/ '{ print $1 "//" $3 "/" }' | sort -u)
    # Split the URLs by line breaks
    IFS=$'\n' read -r -d '' -a url_array <<< "$urls"
    new_urls=()
    for url in "${url_array[@]}"
    do
      # Remove "http://" URLs
      if [[ $url != *"http://"* ]]; then
        # Remove URLs with spaces
        if [[ $url != *" "* ]]; then
          # Replace "./" with "/"
          url=${url//.\//}
          # Remove trailing dot (if present)
          url=${url%/}
          # Add a trailing slash if missing
          if [[ $url != */ ]]; then
            url="$url/"
          fi
          # Add the modified URL to the new_urls array
          new_urls+=("$url")
        fi
      fi
    done
    # Join the modified URLs with line breaks
    new_urls_str=$(printf "%s\n" "${new_urls[@]}")
    echo ""
    echo "----------------------------------------------------------------------"
    echo "List of URLs to be whitelisted for the script to be able to run fully:"
    echo "----------------------------------------------------------------------"
    echo "$new_urls_str"
    echo "----------------------------------------------------------------------"
    echo ""
    exit 0
elif [ "$1" == "--support" ]; then
    echo ""
    echo "-----------------------------------"
    echo "Latest supported SAS Viya versions:"
    echo "-----------------------------------"
    echo "- Stable $LSVIYASTABLE"
    echo "- LTS $LSVIYALTS"
    echo "-----------------------------------"
    echo "NOTE: The tool is not maintained by SAS Institute Inc."
    echo "For support, open an issue at https://github.com/tonineri/viya4-init-tool"
    echo ""
    exit 0
elif [ "$1" == "--help" ]; then
    echo -e ""
    echo -e "-----------------------------------------------------------------------------------------------"
    echo -e "|                           SAS Viya 4 Initialization Tool - Usage                            |"
    echo -e "-----------------------------------------------------------------------------------------------"
    echo -e "|   OPTION   |         EXAMPLE COMMAND          |                 DESCRIPTION                 |"
    echo -e "|------------|----------------------------------|---------------------------------------------|"
    echo -e "|[no option] | ./viya4-init-tool.sh             | executes the GUI                            |"
    echo -e "|--version   | ./viya4-init-tool.sh --version   | shows the tool's version                    |"
    echo -e "|--whitelist | ./viya4-init-tool.sh --whitelist | prints the URLs to be whitelisted           |"
    echo -e "|--support   | ./viya4-init-tool.sh --support   | shows the latest SAS Viya supported versions|"
    echo -e "|--help      | ./viya4-init-tool.sh --help      | shows the usage message                     |"
    echo -e "-----------------------------------------------------------------------------------------------"
    echo -e ""
    exit 0
fi

# ---------------------------------------------- preRequirements ----------------------------------------------

DATETIME=$(date +'%Y-%m-%d | %H:%M:%S') # DATETIME in YYYY-MM-DD | HH:MM:SS format for logging
echo -e "Input desired SAS Viya namespace name:"
read VIYA_NS
# create "$deploy directory"
if [ ! -d "$HOME/$VIYA_NS/deploy" ]; then
    mkdir -p "$HOME/$VIYA_NS/deploy" && cd "$HOME/$VIYA_NS/deploy"
    deploy="$HOME/$VIYA_NS/deploy"
else
    deploy="$HOME/$VIYA_NS/deploy"
    cd $deploy
fi

# create log
LOG="$HOME/$VIYA_NS/viya4-init-tool.log"
touch $LOG
echo -e "\n" > $LOG
echo -e "      .:-======-:.      " >> $LOG
echo -e "    .========----==:    " >> $LOG
echo -e "   -=====-.        .:   " >> $LOG
echo -e "  -=====.               " >> $LOG
echo -e "  =====.   :==-         " >> $LOG
echo -e "  -====.   :====:       " >> $LOG
echo -e "   ====-    .=====.     " >> $LOG
echo -e "    -====.    :====-    " >> $LOG
echo -e "     .====-     =====   " >> $LOG
echo -e "       :====:   .====-  " >> $LOG
echo -e "         -==:   .=====  " >> $LOG
echo -e "               .=====-  " >> $LOG
echo -e "   :.        .-=====-   " >> $LOG
echo -e "    :==----========:    " >> $LOG
echo -e "      .:-======-:.      " >> $LOG
echo -e "     viya4-init-tool    " >> $LOG
echo -e "\n" >> $LOG
echo -ne "\n$DATETIME | INFO: Tool inizialized." >> $LOG
echo -e "\n" >> $LOG

# ---------------------------------------------- loadingAnimation ----------------------------------------------

# loadingAnimation | list of animations
loadAniModern=( 0.5 ∙∙∙ $'\e[33m●\e[0m'∙∙ $'∙\e[33m●\e[0m'∙ $'∙∙\e[33m●\e[0m' )

# loadingAnimation | main script and functions
declare -a active_loading_animation

loadingPlayLoop() {
  while true ; do
    for frame in "${active_loading_animation[@]}" ; do
      printf "\r%s" "${frame}"
      sleep "${loading_animation_frame_interval}"
    done
  done
}

loadingStart() {
  printf "\n"
  active_loading_animation=( "${@}" )
  # Extract the delay between each frame from array active_loading_animation
  loading_animation_frame_interval="${active_loading_animation[0]}"
  unset "active_loading_animation[0]"
  tput civis # Hide the terminal cursor
  loadingPlayLoop &
  loading_animation_pid="${!}"
}

loadingStop() {
  kill "${loading_animation_pid}" &> /dev/null
  printf "\n"
  tput cnorm # Restore the terminal cursor
}

# ----------------------------------------------  textStyle ----------------------------------------------

# textStyle | colors
BLACK='\e[30m'
RED='\e[31m'
GREEN='\e[32m'
YELLOW='\e[33m'
BLUE='\e[34m'
MAGENTA='\e[35m'
CYAN='\e[36m'
WHITE='\e[37m'

# textStyle | formats
NONE='\e[0m'
BOLD='\e[1m'
DIM='\e[2m'
ITALIC='\e[3m'
UNDERLINE='\e[4m'
BLINK='\e[5m'
REVERSE='\e[7m'
HIDDEN='\e[8m'

# ---------------------------------------------- mainScript ----------------------------------------------

# -------------------------------------------  selectionMenus  -------------------------------------------

providerMenu(){
clear
    echo -e "${CYAN}__________________________________________________${NONE}"
    echo -e "\n            ${BOLD}${CYAN}Viya4${NONE} ${BOLD}Initialization Tool${NONE}"
    echo -e "${CYAN}__________________________________________________${NONE}"
    echo -e "\n          ${BOLD}| Provider Selection Menu |${NONE}"
    echo -e "\nInput ${BOLD}${CYAN}1${NONE} : for Microsoft Azure (AKS)"
    echo -e "Input ${BOLD}${CYAN}2${NONE} : for Amazon Web Services (EKS)"
    echo -e "Input ${BOLD}${CYAN}3${NONE} : for Google Cloud Plaform (GKE)"
    echo -e "Input ${BOLD}${CYAN}4${NONE} : for Open Source Kubernetes (K8s)"
    echo -e "Input ${BOLD}${YELLOW}s${NONE} : to skip this menu"
    echo -e "Input ${BOLD}${RED}q${NONE} : to exit the tool\n"

    read CLOUDOPT
    while [[ "$CLOUDOPT" -ne 1 ]] && [[ "$CLOUDOPT" -ne 2 ]] && [[ "$CLOUDOPT" -ne 3 ]] && [[ "$CLOUDOPT" -ne 4 ]] && [[ "$CLOUDOPT" != "s" ]] && [[ "$CLOUDOPT" != "q" ]]; do
        clear
        providerMenu
    done
    CLOUDCHECK=0
    case "$CLOUDOPT" in
        "1") while [[ "$CLOUDCHECK" -eq 0 ]]; do
                MICROSOFTAZURE="${BOLD}${CYAN}Microsoft Azure (AKS)${NONE}"
                echo -e "\nCloud Provider: $MICROSOFTAZURE"
                echo -e "Do you confirm? [y/n]"
                read CLOUDCONFIRM
                if [[ "$CLOUDCONFIRM" == y ]]; then
                    CLOUDCHECK=1
                    CLOUD=aks && CLOUDNAME="$MICROSOFTAZURE"
                    modeSelectionMenu
                elif [[ "$CLOUDCONFIRM" == n ]]; then
                    CLOUDCHECK=1
                    providerMenu
                else
                    echo -e "\n${BOLD}${RED}ERROR${NONE}: Invalid input. Accepted inputs [y/n]."
            
                fi
             done;;
        "2") while [[ "$CLOUDCHECK" -eq 0 ]]; do
                AMAZONAWS="${BOLD}${YELLOW}Amazon Web Services (EKS)${NONE}"
                echo -e "\nCloud Provider: $AMAZONAWS"
                echo -e "Do you confirm? [y/n]"
                read CLOUDCONFIRM
                if [[ "$CLOUDCONFIRM" == y ]]; then
                    CLOUDCHECK=1
                    CLOUD=eks && CLOUDNAME="$AMAZONAWS"
                    modeSelectionMenu
                elif [[ "$CLOUDCONFIRM" == n ]]; then
                    CLOUDCHECK=1
                    providerMenu
                else
                    echo -e "\n${BOLD}${RED}ERROR${NONE}: Invalid input. Accepted inputs [y/n]."
            
                fi
             done;;
        "3") while [[ "$CLOUDCHECK" -eq 0 ]]; do
                GOOGLEGCP="${BOLD}${RED}Google Cloud Provider (GKE)${NONE}"
                echo -e "\nCloud Provider: $GOOGLEGCP"
                echo -e "Do you confirm? [y/n]"
                read CLOUDCONFIRM
                if [[ "$CLOUDCONFIRM" == y ]]; then
                    CLOUDCHECK=1
                    CLOUD=gke && CLOUDNAME="$GOOGLEGCP"
                    modeSelectionMenu
                elif [[ "$CLOUDCONFIRM" == n ]]; then
                    CLOUDCHECK=1
                    providerMenu
                else
                    echo -e "\n${BOLD}${RED}ERROR${NONE}: Invalid input. Accepted inputs [y/n]."
                fi
             done;;
        "4") while [[ "$CLOUDCHECK" -eq 0 ]]; do
                OSK8S="${BOLD}${BLUE}Open Source Kubernetes (K8s)${NONE}"
                echo -e "\nCloud Provider: $OSK8S"
                echo -e "Do you confirm? [y/n]"
                read CLOUDCONFIRM
                if [[ "$CLOUDCONFIRM" == y ]]; then
                    CLOUDCHECK=1
                    CLOUD=k8s && CLOUDNAME="$OSK8S"
                    modeSelectionMenu
                elif [[ "$CLOUDCONFIRM" == n ]]; then
                    CLOUDCHECK=1
                    providerMenu
                else
                    echo -e "\n${BOLD}${RED}ERROR${NONE}: Invalid input. Accepted inputs [y/n]."
                fi
             done;;    
        "s") NOCLOUD="${BOLD}No Provider Selected${NONE}"
             CLOUD="none" && CLOUDNAME="$NOCLOUD"
             modeSelectionMenu;;
        "q") exitTool;;
    esac
}

modeSelectionMenu(){
clear
    echo -e "${CYAN}__________________________________________________${NONE}"
    echo -e "\n            ${BOLD}${CYAN}Viya4${NONE} ${BOLD}Initialization Tool${NONE}"
    echo -e "${CYAN}__________________________________________________${NONE}"
    echo -e "\n             ${BOLD}| Mode Selection Menu |${NONE}"
    echo -e "\n${BOLD}${CYAN}default${NONE}:"
    echo -e "- Installs required packages and clients"
    echo -e "- Installs provider CLI (if defined)"
    echo -e "- Downloads order assets, license and certificates"
    echo -e "\n${BOLD}${CYAN}full${NONE}:"
    echo -e "- What default does"
    echo -e "- Installs Terraform and configures it"
    echo -e "- Downloads latest viya4-IaC"
    echo -e "\n${BOLD}${CYAN}clients-only${NONE}:"
    echo -e "- Installs required packages and clients"
    echo -e "- Installs provider CLI (if defined)"
    echo -e "\n${BOLD}${CYAN}order-only${NONE}:"
    echo -e "- Downloads order assets, license and certificates"
    echo -e "\n${BOLD}${CYAN}tf-only${NONE} (if Provider is defined):"
    echo -e "- Installs provider CLI"
    echo -e "- Installs Terraform and configures it"
    echo -e "- Downloads latest viya4-IaC\n"
    echo -e "\n       Provider: $CLOUDNAME"
    echo -e "\n${CYAN}__________________________________________________${NONE}"
    echo -e "\nInput ${BOLD}${CYAN}1${NONE} : for default mode "
    echo -e "Input ${BOLD}${CYAN}2${NONE} : for full mode"
    echo -e "Input ${BOLD}${CYAN}3${NONE} : for clients-only mode"
    echo -e "Input ${BOLD}${CYAN}4${NONE} : for order-only mode"
    echo -e "Input ${BOLD}${CYAN}5${NONE} : for tf-only mode"
    echo -e "Input ${BOLD}${YELLOW}r${NONE} : to return to previous menu"
    echo -e "Input ${BOLD}${RED}q${NONE} : to exit the tool\n"
    
    read MODEOPT
    while [[ "$MODEOPT" -ne 1 ]] && [[ "$MODEOPT" -ne 2 ]] && [[ "$MODEOPT" -ne 3 ]] && [[ "$MODEOPT" -ne 4 ]] && [[ "$MODEOPT" -ne 5 ]] && [[ "$MODEOPT" != "r" ]] && [[ "$MODEOPT" != "q" ]]; do
        clear
        modeSelectionMenu
    done
    MODECHECK=0
    case "$MODEOPT" in
        "1") while [[ "$MODECHECK" -eq 0 ]]; do
                echo -e "\nMode selected: ${CYAN}default${NONE}"
                echo -e "Do you confirm? [y/n]"
                read MODECONFIRM
                if [[ "$MODECONFIRM" == y ]]; then
                    MODECHECK=1
                    MODESELECTED="defaultMode"
                    defaultMode
                elif [[ "$MODECONFIRM" == n ]]; then
                    MODECHECK=1
                    modeSelectionMenu
                else
                    echo -e "\n${BOLD}${RED}ERROR${NONE}: Invalid input. Accepted inputs [y/n]."
                fi
             done;;
        "2") while [[ "$MODECHECK" -eq 0 ]]; do
                echo -e "\nMode selected: ${CYAN}full${NONE}"
                echo -e "Do you confirm? [y/n]"
                read MODECONFIRM
                if [[ "$MODECONFIRM" == y ]]; then
                    MODECHECK=1
                    MODESELECTED="fullMode"
                    fullMode
                elif [[ "$MODECONFIRM" == n ]]; then
                    MODECHECK=1
                    modeSelectionMenu
                else
                    echo -e "\n${BOLD}${RED}ERROR${NONE}: Invalid input. Accepted inputs [y/n]."
                fi
             done;;
        "3") while [[ "$MODECHECK" -eq 0 ]]; do
                echo -e "\nMode selected: ${CYAN}clients-only${NONE}"
                echo -e "Do you confirm? [y/n]"
                read MODECONFIRM
                if [[ "$MODECONFIRM" == y ]]; then
                    MODECHECK=1
                    MODESELECTED="clientsOnlyMode"
                    clientsOnlyMode
                elif [[ "$MODECONFIRM" == n ]]; then
                    MODECHECK=1
                    modeSelectionMenu
                else
                    echo -e "\n${BOLD}${RED}ERROR${NONE}: Invalid input. Accepted inputs [y/n]."
                fi
             done;;
        "4") while [[ "$MODECHECK" -eq 0 ]]; do
                echo -e "\nMode selected: ${CYAN}order-only${NONE}"
                echo -e "Do you confirm? [y/n]"
                read MODECONFIRM
                if [[ "$MODECONFIRM" == y ]]; then
                    MODECHECK=1
                    MODESELECTED="orderOnlyMode"
                    orderOnlyMode
                elif [[ "$MODECONFIRM" == n ]]; then
                    MODECHECK=1
                    modeSelectionMenu
                else
                    echo -e "\n${BOLD}${RED}ERROR${NONE}: Invalid input. Accepted inputs [y/n]."
                fi
             done;;
        "5") while [[ "$MODECHECK" -eq 0 ]]; do
                echo -e "\nMode selected: ${CYAN}tf-only${NONE}"
                echo -e "Do you confirm? [y/n]"
                read MODECONFIRM
                if [[ "$MODECONFIRM" == y ]]; then
                    MODECHECK=1
                    MODESELECTED="tfOnlyMode"
                    tfOnlyMode
                elif [[ "$MODECONFIRM" == n ]]; then
                    MODECHECK=1
                    modeSelectionMenu
                else
                    echo -e "\n${BOLD}${RED}ERROR${NONE}: Invalid input. Accepted inputs [y/n]."
                fi
             done;;
        "r") providerMenu;;
        "q") exitTool;;
    esac
}

exitTool() {
    echo -ne "\n$DATETIME | INFO: Tool execution completed." >> $LOG
    echo -e "\nThank you for using this tool.\n"
    exit 0
}

# -------------------------------------------  requirements  -------------------------------------------
requiredPackages() {
    # requiredPackages | log
    echo -ne "\n$DATETIME | INFO: Required packages installation procedure started." >> $LOG
    # requiredPackages | pre-installation
    cd $deploy
    echo -ne "Installing required packages. This might take a minute or two...\n"
    loadingStart "${loadAniModern[@]}"
    requiredPackages=("zsh" "zip" "unzip" "git" "mlocate" "jq" "bat")
    # requiredPackages | installation
    for package in "${requiredPackages[@]}"; do
        sudo apt install $package -y -qq >> $LOG 2>&1
    done
    rm -rf $HOME/.oh-my-zsh >> $LOG 2>&1
    curl -fsSL -o zsh-install.sh https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh >> $LOG 2>&1
    sudo chmod +x zsh-install.sh && ./zsh-install.sh --unattended >> $LOG 2>&1
    rm -f zsh-install.sh >> $LOG 2>&1
    sh -c "$(curl -fsSL https://github.com/ohmyzsh/ohmyzsh/blob/master/tools/install.sh)" "" --unattended >> $LOG 2>&1
    # requiredPackages | zsh customization
    git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions >> $LOG 2>&1
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting >> $LOG 2>&1
    git clone https://github.com/jonmosco/kube-ps1.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/kube-ps1 >> $LOG 2>&1
    zshrcContent
    # requiredPackages | updatedb for mlocate
    sudo updatedb >> $LOG 2>&1
    # requiredPackages | post-installation & check if all required packages were installed
    loadingStop
    not_installed=()
    for package in "${requiredPackages[@]}"; do
    if [[ ! $(dpkg -s "$package" >> $LOG 2>&1) ]]; then
        not_installed+=("$package")
    fi
    done
    if [ ${#not_installed[@]} -eq 0 ]; then
      echo -ne "\n${BOLD}${RED}ERROR${NONE}: ${not_installed[@]} failed to install. Check $LOG for details."
    else
      echo -ne "\n${BOLD}${GREEN}SUCCESS${NONE}: All required packages installed."
    fi
    echo -e "\n"
}

# -----------------------------------------  cloudProviderCLIs  ----------------------------------------

az-cli() {
    # az-cli | log
    echo -ne "\n$DATETIME | INFO: azure-cli nstallation procedure started." >> $LOG
    # az-cli | pre-installation
    cd $deploy
    echo -ne "Installing latest ${CYAN}azure-cli${NONE}..."
    loadingStart "${loadAniModern[@]}"
    # az-cli | installation
    echo -ne "\n$DATETIME | INFO: Downloading https://aka.ms/InstallAzureCLIDeb and executing." >> $LOG 2>&1
    curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash >> $LOG 2>&1
    # az-cli | post-installation & check if all required packages were installed
    loadingStop
    if which az >/dev/null 2>&1; then
        echo -ne "\n${BOLD}${GREEN}SUCCESS${NONE}: azure-cli $(az version -o yaml | awk 'NR==1{print $2}') installed."
    else
        echo -ne "\n${BOLD}${RED}ERROR${NONE}: azure-cli installation failed. Check $LOG for details."
    fi
    echo -e "\n"
}

aws-cli() {
    # aws-cli | log
    echo -ne "\n$DATETIME | INFO: aws-cli installation procedure started." >> $LOG
    # aws-cli | pre-installation
    cd $deploy
    echo -e "Installing latest ${YELLOW}aws-cli${NONE}..."
    loadingStart "${loadAniModern[@]}"
    # aws-cli | installation
    curl -s "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" >> $LOG 2>&1
    unzip -qq awscliv2.zip >> $LOG 2>&1
    sudo ./aws/install >> $LOG 2>&1
    # aws-cli | post-installation & check if all required packages were installed
    loadingStop
    if which aws >/dev/null 2>&1; then
        echo -ne "\n${BOLD}${GREEN}SUCCESS${NONE}: aws-cli v$(aws --version | awk 'NR==1{print $1}' | cut -d"/" -f2) installed."
    else
        echo -ne "\n${BOLD}${RED}ERROR${NONE}: aws-cli installation failed. Check $LOG for details."
    fi
    echo -e "\n"
}

gcloud-cli() {
    # gcloud-cli | log
    echo -ne "\n$DATETIME | INFO: gcloud-cli installation procedure started." >> $LOG
    # gcloud-cli | pre-installation
    cd $deploy
    echo -e "Installing latest ${RED}gcloud-cli${NONE}..."
    loadingStart "${loadAniModern[@]}"
    # gcloud-cli | installation
    sudo apt-get install apt-transport-https ca-certificates gnupg -y >> $LOG 2>&1
    echo "deb https://packages.cloud.google.com/apt cloud-sdk main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list >> $LOG 2>&1
    curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg > /tmp/google-cloud-sdk-key.gpg && sudo gpg --import /tmp/google-cloud-sdk-key.gpg >> $LOG 2>&1
    sudo apt-get update -y -qq >> $LOG 2>&1
    sudo apt-get install google-cloud-cli -y -qq >> $LOG 2>&1
    # gcloud-cli | post-installation & check if all required packages were installed
    loadingStop
    if which gcloud >/dev/null 2>&1; then
        echo -ne "\n${BOLD}${GREEN}SUCCESS${NONE}: gcloud-cli v$(gcloud version | awk 'NR==1{print $4}') installed."
    else
        echo -ne "\n${BOLD}${RED}ERROR${NONE}: gcloud-cli installation failed. Check $LOG for details."
    fi
    echo -e "\n"
}

k8s() {
    # k8s | log
    echo -ne "\n$DATETIME | INFO: ansible and docker installation procedure started." >> $LOG
    # k8s | pre-installation
    cd $deploy
    echo -e "Installing latest docker..."
    loadingStart "${loadAniModern[@]}"
    # k8s | docker installation
    sudo apt install -y -qq ca-certificates curl gnupg lsb-release >> $LOG 2>&1
    if [[ ! -d "/etc/apt/keyrings" ]]; then
        mkdir -m 0755 -p /etc/apt/keyrings
    fi
    if [[ ! -s "/etc/apt/keyrings/docker.gpg" ]]; then
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg >> $LOG 2>&1
    fi
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null >> $LOG 2>&1
    sudo apt-get update -y -qq >> $LOG 2>&1
    sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y -qq >> $LOG 2>&1
    loadingStop
    if which docker >/dev/null 2>&1; then
        echo -ne "\n${BOLD}${GREEN}SUCCESS${NONE}: docker $(docker --version | cut -d" " -f3 | cut -d"," -f1) installed."
    else
        echo -ne "\n${BOLD}${RED}ERROR${NONE}: docker installation failed. Check $LOG for details."
    fi
    # k8s | ansible supported version
    ANSIVER="2.13.4"
    # k8s | ansible installation
    echo -e "\nInstalling ansible-core $ANSIVER..."
    loadingStart "${loadAniModern[@]}"
    sudo apt-get install python3 -y -qq >> $LOG 2>&1
    curl -sfSL https://bootstrap.pypa.io/get-pip.py -o get-pip.py >> $LOG 2>&1
    python3 get-pip.py --user >> $LOG 2>&1
    python3 -m pip install --user ansible-core==$ANSIVER --no-warn-script-location >> $LOG 2>&1
    source $HOME/.profile
    # k8s | post-installation
    loadingStop
    ANSIPING=$(ansible localhost -m ping 2>/dev/null)
    if which ansible >/dev/null 2>&1 && [[ "$ANSIPING" == *SUCCESS* ]]; then
        rm -f get-pip.py
        echo -ne "\n${BOLD}${GREEN}SUCCESS${NONE}: ansible-$(ansible --version | head -n1 | cut -d"[" -f2 | cut -d"]" -f1) installed."
    else
        echo -ne "\n${BOLD}${RED}ERROR${NONE}: ansible installation failed. Check $LOG for details."
    fi
    echo -e "\n"
}

# --------------------------------------------  zshrc contents  -------------------------------------------
zshrcContent() {
tee ~/.zshrc >> /dev/null << EOF
# zsh
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="robbyrussell"
plugins=(git zsh-autosuggestions zsh-syntax-highlighting kubectl)
source $ZSH/oh-my-zsh.sh

#ZSH_THEME="agnoster"

TERM=xterm-256color

# Global
export KUBECONFIG=~/path/to/kubeconfig
alias bat="batcat"
alias ll="ls -la"

# SAS Viya variables
export ORDER=9CXXX
export CADENCE=lts
export VERSION=2023.03
export VIYA_NS=\$VIYA_NS
export deploy=~/\$HOME/\$VIYA_NS/deploy

# Container Registry
export REGISTRY=cr.hostname.com
export REGISTRY_USER=username
export REGISTRY_PASS="Passw0rd1"

# SAS Viya aliases
alias setviya="kubectl config set-context --current --namespace=\$VIYA_NS"
alias kb="cd \$deploy && kustomize build -o site.yaml"
alias start-sas-viya="kubectl create job sas-start-all-`date +%s` --from cronjobs/sas-start-all -n \$VIYA_NS"
alias stop-sas-viya="kubectl create job sas-stop-all-`date +%s` --from cronjobs/sas-stop-all -n \$VIYA_NS"
alias status-sas-viya="watch -n1 'kubectl get sasdeployments -n \$VIYA_NS && echo -e && kubectl get pods -n \$VIYA_NS'"
alias k9s-sas-viya="k9s --kubeconfig \$KUBECONFIG --namespace \$VIYA_NS"
alias docker-sas-viya="docker run --rm -v ~/sas-viya/\$VIYA_NS:/cwd/ sas-orchestration create sas-deployment-cr --deployment-data /cwd/license/SASViyaV4_certs.zip --license /cwd/license/license.jwt --user-content /cwd/deploy --cadence-name \$CADENCE --cadence-version \$VERSION --cadence-release \$RELEASE --image-registry \$REGISTRY > \$deploy/\$VIYA_NS-sasdeployment.yaml"
#alias podman-sas-viya="podman run --rm -v ~/sas-viya/\$VIYA_NS:/cwd/ sas-orchestration create sas-deployment-cr --deployment-data /cwd/license/SASViyaV4_certs.zip --license /cwd/license/license.jwt --user-content /cwd/deploy --cadence-name \$CADENCE --cadence-version \$VERSION --cadence-release \$RELEASE --image-registry \$REGISTRY --repository-warehouse http://hostname.com/sas_repos > \$deploy/\$VIYA_NS-sasdeployment.yaml"
EOF
}

# -------------------------------------------  requiredClients  -------------------------------------------
requiredClients() {
    # requiredClients | log
    echo -ne "\n$DATETIME | INFO: Required clients installation procedure started." >> $LOG
    # requiredClients: kubectl | log
    echo -ne "\n$DATETIME | INFO: Required clients - kubectl installation procedure started." >> $LOG
    # requiredClients: kubectl | input
    KCTLVERMINSUPPORTED="22" # <--- Minimum supported version
    KCTLVERMAXSUPPORTED="26" # <--- Maximum supported version
    echo -e "${BOLD}${YELLOW}----------------------------${NONE}"
    echo -e "${BOLD}${YELLOW}       INPUT REQUIRED       ${NONE}"
    echo -e "${BOLD}${YELLOW}----------------------------${NONE}"
    KUBECTLCHECK=0
    while [[ "$KUBECTLCHECK" -eq 0 ]]; do
        echo -e "Input kubectl version to be installed based on your Kubernetes Cluster version (example 1.24.10):"
        echo -e "Supported versions: 1.22.0 - 1.26.XX"
        read KUBECTLVER
        KCTLVERMAJ=$(echo $KUBECTLVER | cut -d"." -f1)
        KCTLVERMIN=$(echo $KUBECTLVER | cut -d"." -f2)
        if [[ "$KCTLVERMAJ" -eq 1 ]] && [[ "$KCTLVERMIN" -ge "$KCTLVERMINSUPPORTED" ]] && [[ "$KCTLVERMIN" -le "$KCTLVERMAXSUPPORTED" ]]; then
            # requiredClients: kubectl | pre-installation
            echo -e "Installing kubectl $KUBECTLVER..."
            cd $deploy
            loadingStart "${loadAniModern[@]}"
            # requiredClients: kubectl | installation
            curl -LO "https://dl.k8s.io/release/v${KUBECTLVER}/bin/linux/amd64/kubectl" >> $LOG 2>&1
            if [ $(stat -c%s kubectl) -lt 10240 ]; then
              loadingStop
              rm -f kubectl
              echo -ne "\n${BOLD}${RED}ERROR${NONE}: kubectl version does not exist."
            else
              sudo install kubectl -o root -g root -m 755 /usr/local/bin >> $LOG 2>&1
              rm -f kubectl
            fi
            # requiredClients: kubectl | post-installation & check if installed
            loadingStop
            if which kubectl >/dev/null 2>&1; then
                KUBECTLCHECK=1
                echo -ne "\n${BOLD}${GREEN}SUCCESS${NONE}: kubectl $(kubectl version --client --short 2>/dev/null | awk 'NR==1{print $3}') installed."
            else
                echo -ne "\n${BOLD}${RED}ERROR${NONE}: kubectl installation failed. Check $LOG for details."
            fi
        else 
            echo -e "\n${BOLD}${RED}ERROR${NONE}: Kubectl version is incorrect, unsupported or null."
        fi
        echo -e "\n"
    done
    # requiredClients: kustomize | log
    echo -ne "\n$DATETIME | INFO: Required clients - kustomize installation procedure started." >> $LOG
    # requiredClients: kustomize | input
    KUSTOMIZESUPPORTED1="3.7.0" # for SAS Viya <= SAS Viya 2023.01
    KUSTOMIZESUPPORTED2="4.5.7" # for SAS Viya 2023.02 - performance issues!
    KUSTOMIZESUPPORTED3="5.0.0" # for SAS Viya >= 2023.03 and <= 2023.05
    KUSTOMIZESUPPORTED4="5.0.3" # for SAS Viya 2023.06 or later
    echo -e "${BOLD}${YELLOW}----------------------------${NONE}"
    echo -e "${BOLD}${YELLOW}       INPUT REQUIRED       ${NONE}"
    echo -e "${BOLD}${YELLOW}----------------------------${NONE}"
    KUSTOCHECK=0
    while [[ "$KUSTOCHECK" -eq 0 ]]; do
        echo -e "Supported kustomize versions:"
        echo -e "$KUSTOMIZESUPPORTED1 | SAS Viya <= 2023.01 "
        echo -e "$KUSTOMIZESUPPORTED2 | SAS Viya 2023.02 - performance issues!"
        echo -e "$KUSTOMIZESUPPORTED3 | SAS Viya >= 2023.03 and <= 2023.05"
        echo -e "$KUSTOMIZESUPPORTED4 | SAS Viya 2023.06 or later"
        echo ""
        echo -e "Input kustomize version to be installed based on your SAS Viya version:"
        read KUSTOMIZEVERSION
        if [[ "$KUSTOMIZEVERSION" == "$KUSTOMIZESUPPORTED1" ]] || [[ "$KUSTOMIZEVERSION" == "$KUSTOMIZESUPPORTED2" ]] || [[ "$KUSTOMIZEVERSION" == "$KUSTOMIZESUPPORTED3" ]] || [[ "$KUSTOMIZEVERSION" == "$KUSTOMIZESUPPORTED4" ]]; then
            # requiredClients: kustomize | pre-installation
            echo -e "Installing kustomize $KUSTOMIZEVERSION..."
            cd $deploy
            loadingStart "${loadAniModern[@]}"
            # requiredClients: kustomize | installation
            wget "https://github.com/kubernetes-sigs/kustomize/releases/download/kustomize%2Fv${KUSTOMIZEVERSION}/kustomize_v${KUSTOMIZEVERSION}_linux_amd64.tar.gz" >> $LOG 2>&1
            tar xvf kustomize_v${KUSTOMIZEVERSION}_linux_amd64.tar.gz > /dev/null >> $LOG 2>&1
            sudo install kustomize -o root -g root -m 755 /usr/local/bin/kustomize >> $LOG 2>&1
            rm -f kustomize*
            # requiredClients: kustomize | post-installation & check if installed
            loadingStop
            if which kustomize >/dev/null 2>&1; then
                KUSTOCHECK=1
                echo -ne "\n${BOLD}${GREEN}SUCCESS${NONE}: kustomize $(kustomize version) installed."
            else
                echo -ne "\n${BOLD}${RED}ERROR${NONE}: kustomize installation failed. Check $LOG for details."
            fi
        else 
            echo -e "\n${BOLD}${RED}ERROR${NONE}: Kustomize version is incorrect, unsupported or null."
        fi
        echo -e "\n"
    done
    # requiredClients: node-shell | log
    echo -ne "\n$DATETIME | INFO: Required clients - node-shell installation procedure started." >> $LOG
    # requiredClients: node-shell | pre-installation
    echo -e "Installing latest node-shell..."
    cd $deploy
    loadingStart "${loadAniModern[@]}"
    # requiredClients: node-shell | installation
    curl -fsSL -o kubectl-node_shell https://raw.githubusercontent.com/kvaps/kubectl-node-shell/master/kubectl-node_shell >> $LOG 2>&1
    sudo install kubectl-node_shell -o root -g root -m 755 /usr/local/bin/node-shell >> $LOG 2>&1
    rm -f kubectl-node_shell
    # requiredClients: node-shell | post-installation & check if installed
    loadingStop
    if which node-shell >/dev/null 2>&1; then
        echo -ne "\n${BOLD}${GREEN}SUCCESS${NONE}: node-shell $(node-shell --version | awk 'NR==1{print $2}') installed."
    else
        echo -ne "\n${BOLD}${RED}ERROR${NONE}: node-shell installation failed. Check $LOG for details."
    fi
    echo -e "\n"
    # requiredClients: helm 3 | log
    echo -ne "\n$DATETIME | INFO: Required clients - helm 3 installation procedure started." >> $LOG
    # requiredClients: helm 3 | pre-installation
    echo -e "Installing latest helm 3..."
    cd $deploy
    loadingStart "${loadAniModern[@]}"
    # requiredClients: helm 3 | installation
    curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 >> $LOG 2>&1
    chmod 700 get_helm.sh && ./get_helm.sh >> $LOG 2>&1
    rm -f get_helm.sh
    # requiredClients: helm 3 | post-installation & check if installed
    loadingStop
    if which helm >/dev/null 2>&1; then
        echo -ne "\n${BOLD}${GREEN}SUCCESS${NONE}: Helm $(helm version --short | cut -d+ -f1) installed."
    else
        echo -ne "\n${BOLD}${RED}ERROR${NONE}: Helm installation failed. Check $LOG for details."
    fi
    echo -e "\n"
    # requiredClients: yq | log
    echo -ne "\n$DATETIME | INFO: Required clients - yq installation procedure started." >> $LOG
    # requiredClients: yq | pre-installation
    echo -e "Installing latest yq..."
    cd $deploy
    loadingStart "${loadAniModern[@]}"
    # requiredClients: yq | installation
    wget https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64 >> $LOG 2>&1
    sudo install yq_linux_amd64 -o root -g root -m 755 /usr/local/bin/yq >> $LOG 2>&1
    rm -f yq_linux_amd64
    # requiredClients: yq | post-installation & check if installed
    loadingStop
    if which yq >/dev/null 2>&1; then
        echo -ne "\n${BOLD}${GREEN}SUCCESS${NONE}: yq $(yq --version | cut -d" " -f4) installed."
    else
        echo -ne "\n${BOLD}${RED}ERROR${NONE}: yq installation failed. Check $LOG for details."
    fi
    echo -e "\n"
    # requiredClients: k9s | log
    echo -ne "\n$DATETIME | INFO: Required clients - k9s installation procedure started." >> $LOG
    # requiredClients: k9s | pre-installation
    echo -e "Installing latest k9s..."
    cd $deploy
    loadingStart "${loadAniModern[@]}"
    # requiredClients: k9s | installation
    wget https://github.com/derailed/k9s/releases/latest/download/k9s_Linux_amd64.tar.gz >> $LOG 2>&1
    tar xf k9s_Linux_amd64.tar.gz >> $LOG 2>&1
    sudo install k9s -o root -g root -m 755 /usr/local/bin/k9s >> $LOG 2>&1
    rm -f k9s_Linux_amd64.tar.gz k9s
    # requiredClients: k9s | post-installation & check if installed
    loadingStop
    if which k9s >/dev/null 2>&1; then
        echo -ne "\n${BOLD}${GREEN}SUCCESS${NONE}: k9s $(k9s version | grep "Version:" | awk '{print $2}') installed."
    else
        echo -ne "\n${BOLD}${RED}ERROR${NONE}: k9s installation failed. Check $LOG for details."
    fi
    echo -e "\n"
}

# ---------------------------------------------  orderDownload  --------------------------------------------

viya4OrdersCli() {
    # viya4OrdersCli | log
    echo -ne "\n$DATETIME | INFO: viya4-orders-cli installation procedure started." >> $LOG
    # viya4OrdersCli | pre-installation
    echo -e "Installing latest viya4-orders-cli..."
    cd $deploy
    loadingStart "${loadAniModern[@]}"
    # viya4OrdersCli | pre-installation 
    wget https://github.com/sassoftware/viya4-orders-cli/releases/latest/download/viya4-orders-cli_linux_amd64 >> $LOG 2>&1
    sudo install viya4-orders-cli_linux_amd64 -o root -g root -m 755 /usr/local/bin/viya4-orders-cli >> $LOG 2>&1
    rm -f viya4-orders-cli_linux_amd64
    # viya4OrdersCli | post-installation
    loadingStop
    if which viya4-orders-cli >/dev/null 2>&1; then
        VIYA4ORDERSCLICHECK=1
        echo -ne "\n${BOLD}${GREEN}SUCCESS${NONE}: viya4-orders-cli $(viya4-orders-cli --version | cut -d" " -f3) installed."
        echo -e "\n"
        clientCredentials
    else
        VIYA4ORDERSCLICHECK=0
        echo -ne "\n${BOLD}${RED}ERROR${NONE}: viya4-orders-cli installation failed. Check $LOG for details."
    fi
    echo -e "\n"
}

clientCredentials() {
    # clientCredentials | log
    echo -ne "\n$DATETIME | INFO: clientCredentials definition procedure started." >> $LOG
    # viya4OrdersCli | define clientCredentials
    if [[ "$VIYA4ORDERSCLICHECK" -eq 1 ]]; then
      echo -e "${BOLD}${YELLOW}----------------------------${NONE}"
      echo -e "${BOLD}${YELLOW}       INPUT REQUIRED       ${NONE}"
      echo -e "${BOLD}${YELLOW}----------------------------${NONE}"
      echo -e "${BOLD}${YELLOW}NOTE${NONE}: The script doesn't check whether your clientCredentials are correct or not."
      echo -e "Make sure you're copy/pasting your clientCredentials directly from https://apiportal.sas.com/my-apps."
      sleep 3
      VIYA4CREDSAVED=0
      while [[ "$VIYA4CREDSAVED" -eq 0 ]]; do
        echo -e "\nInput your clientCredentialsId ${BOLD}${CYAN}(Key)${NONE}:"
        read CLCREDID
        CLCREDIDB64=$(echo -n $CLCREDID | base64)
        echo -e "\nInput your clientCredentialsSecret ${BOLD}${CYAN}(Secret)${NONE}:"
        read CLCREDSEC
        CLCREDSECB64=$(echo -n $CLCREDSEC | base64) 
        echo -e "clientCredentialsId: $CLCREDIDB64\nclientCredentialsSecret: $CLCREDSECB64" > $HOME/.viya4-orders-cli
        unset CLCREDID CLCREDSEC CLCREDIDB64 CLCREDSECB64
        if [[ -s $HOME/.viya4-orders-cli ]]; then
          VIYA4CREDSAVED=1
          echo -e "\n${BOLD}${GREEN}SUCCESS${NONE}: Your clientCredentials were encoded and saved in $HOME/.viya4-orders-cli."
        fi
      done
    else
      echo -ne "\n${BOLD}${RED}ERROR${NONE}: viya4-orders-cli is not installed.\n"
      echo -e "${BOLD}${YELLOW}----------------------------${NONE}"
      echo -e "${BOLD}${YELLOW}       INPUT REQUIRED       ${NONE}"
      echo -e "${BOLD}${YELLOW}----------------------------${NONE}"
      RETURNSELECTIONCC=0
      while [[ "$RETURNSELECTIONCC" -eq 0 ]]; do
          echo -e "Input ${BOLD}${YELLOW}1${NONE} : to retry viya4-orders-cli installation."
          echo -e "Input ${BOLD}${YELLOW}q${NONE} : to exit the tool."
          echo -e "\n"
          read RETURNSELECTCC
          if [[ "$RETURNSELECTCC" -eq 1 ]]; then
            RETURNSELECTIONCC=1
            viya4OrdersCli
          elif [[ "$RETURNSELECTCC" == "q" ]]; then
            RETURNSELECTIONCC=1
            exitTool
          else
            echo -e "\n${BOLD}${RED}ERROR${NONE}: Invalid input. Accepted inputs [1/q]."
          fi
      done
    fi
}

getOrder() {
    # getOrder | log
    echo -ne "\n$DATETIME | INFO: Order download procedure started." >> $LOG
    # getOrder | input order number
    echo -e "${BOLD}${YELLOW}----------------------------${NONE}"
    echo -e "${BOLD}${YELLOW}       INPUT REQUIRED       ${NONE}"
    echo -e "${BOLD}${YELLOW}----------------------------${NONE}"
    ORDERCHECK=0
    while [[ "$ORDERCHECK" -eq 0 ]]; do
      echo -e "Input software Order Number (example 9CT4FQ):"
      read ORDER
      # getOrder | check if order number is valid (6 characters / second character is a capital letter / only numbers and caps / starts with 0 or 9C) - set ORDERCHECK1=true
      if [[ ${#ORDER} -eq 6 ]] && [[ $(echo $ORDER | cut -b2) =~ ^[A-Z]+$ ]] && [[ $(echo $ORDER) =~ ^[0-9A-Z]+$ ]] && [[ $(echo $ORDER) =~ ^(0|9C) ]]; then
          ORDERCHECK=1
      else
          echo -e "\n${BOLD}${RED}ERROR${NONE}: Invalid Order Number."
          echo -e "${BOLD}${YELLOW}NOTE${NONE}: A valid Order Number:"
          echo -e "- Consists of 6 alphanumeric [0-9,A-Z] characters (no lowercase)"
          echo -e "- Starts with '0' (if internal) or '9C' (if external)"
          echo -e "- If the second character is capital letter 'C' for external orders or [A-Z] for internal ones"
      fi
    done
    ## getOrder | input cadence
    CADENCECHECK=0
    while [[ "$CADENCECHECK" -eq 0 ]] ; do
        echo -e "\nInput software Cadence [stable/lts]:"
        read CADENCE
        ### getOrder | check if cadence is valid
        if [[ "$CADENCE" == stable ]] || [[ "$CADENCE" == lts ]]; then
            CADENCECHECK=1
        else
            echo -e "\n${BOLD}${RED}ERROR${NONE}: Invalid software Cadence. Accepted inputs [stable/lts]."
        fi
    done
    ## getOrder | input version
    VERSIONCHECK=0
    while [[ "$VERSIONCHECK" -eq 0 ]]; do
        echo -e "\nInput SAS Viya software version (example 2023.03):"
        read VERSION
        VERSIONY=$(echo $VERSION | cut -d"." -f1)
        VERSIONM=$(echo $VERSION | cut -d"." -f2)
        VERSIONMOCTAL=$(echo $VERSION | cut -d"." -f2 | sed 's/^0*//') # remove leading zero
        # getOrder | check if version is valid / supported
        ## accept only 2022.[09-12] versions for 2022 and limit version characters to 7
        if [[ "$VERSIONY" -eq 2022 ]] && [[ "$VERSIONMOCTAL" -ge 9 && "$VERSIONMOCTAL" -le 12 ]] && [[ ${#VERSION} -eq 7 ]]; then
            if [[ "$CADENCE" == lts ]] && [[ "$VERSIONMOCTAL" != 9 ]]; then
              echo -e "\n${BOLD}${RED}ERROR${NONE}: The only 2022 LTS version supported is 2022.09"
            else
              VERSIONCHECK=1
            fi
        ## accept 2023.01 and later versions without limiting yet unreleased versions and limit version characters to 7
        elif [[ "$VERSIONY" -ge 2023 ]] && [[ "$VERSIONMOCTAL" -ge 1 && "$VERSIONMOCTAL" -le 12 ]] && [[ ${#VERSION} -eq 7 ]]; then
          if [[ "$CADENCE" == lts ]] && [[ "$VERSIONY" -ge 2023 ]] && [[ "$VERSIONMOCTAL" != 3 && "$VERSIONMOCTAL" != 9 ]]; then
            echo -e "\n${BOLD}${RED}ERROR${NONE}: LTS versions can only be YYYY.03 or YYYY.09"
          else
            VERSIONCHECK=1
          fi
        else
            echo -e "\n${BOLD}${RED}ERROR${NONE}: Invalid or unsupported software Version."
            echo -e "Supported versions: Min 2022.09 | Max latest available Stable/LTS version."
        fi
    done
    ## getOrder | ask for info confirmation
    CONFIRMCHECK=0
    while [[ "$CONFIRMCHECK" -eq 0 ]]; do
        echo -e "${YELLOW}-----------------${NONE}"
        echo -e "Order:   $ORDER"
        echo -e "Cadence: $CADENCE"
        echo -e "Version: $VERSION"
        echo -e "${YELLOW}-----------------${NONE}"
        echo -e "\nDo you confirm? [y/n]"
        read CONFIRM
        if [[ "$CONFIRM" == y ]]; then
            # getOrder | pre-download
            CONFIRMCHECK=1
            echo -e "\nDownloading deploymentAssets, license and certificates..."
            cd $deploy
            loadingStart "${loadAniModern[@]}"
            # getOrder | download
            RELEASE=$(viya4-orders-cli deploymentAssets $ORDER $CADENCE $VERSION --file-name assets 2>/dev/null | grep CadenceRelease | cut -d' ' -f2) >> $LOG 2>&1
            echo $RELEASE > current_release.txt
            tar xf assets.tgz >> $LOG 2>&1
            if [[ ! -d "$HOME/deploy/license" ]]; then
              mkdir ~/deploy/license >> $LOG 2>&1
            fi
            cd $deploy/license >> $LOG 2>&1
            viya4-orders-cli license $ORDER $CADENCE $VERSION --file-name license >> $LOG 2>&1
            viya4-orders-cli certs $ORDER >> $LOG 2>&1
            cd $deploy
            # getOrder | post-download checks
            loadingStop
            if [[ -f "$HOME/deploy/assets.tgz" && -d "$HOME/deploy/license" && -f "$HOME/deploy/license/license.jwt" && -f "$HOME/deploy/license/SASViyaV4_${ORDER}_certs.zip" ]]; then
                printFinalDate
                echo -e "\n${BOLD}${GREEN}SUCCESS${NONE}: DeploymentAssets, license and certificates downloaded in ~/deploy."
            else
                RETURNSELECTION=0
                echo -e "\n${BOLD}${RED}ERROR${NONE}: Issue while downloading deploymentAssets, license and certificates."
                echo -e "${BOLD}${YELLOW}NOTE${NONE}: Possible causes:"
                echo -e "- Invalid previously defined clientCredentials."
                echo -e "- Defined version is not available yet."
                echo -e "- You don't have permission to access this order. Make sure you can see it in https://my.sas.com."
                echo -e "- Order does not exist."
                echo -e "\n"
                echo -e "${BOLD}${YELLOW}----------------------------${NONE}"
                echo -e "${BOLD}${YELLOW}       INPUT REQUIRED       ${NONE}"
                echo -e "${BOLD}${YELLOW}----------------------------${NONE}"
                while [[ "$RETURNSELECTION" -eq 0 ]]; do
                    echo -e "Input ${BOLD}${YELLOW}1${NONE} : to re-insert order information."
                    echo -e "Input ${BOLD}${YELLOW}2${NONE} : to re-insert your clientCredentials."
                    echo -e "Input ${BOLD}${YELLOW}q${NONE} : to exit the tool."
                    echo -e "\n"
                    read RETURNSELECT
                    if [[ "$RETURNSELECT" -eq 1 ]]; then
                      RETURNSELECTION=1
                      getOrder
                    elif [[ "$RETURNSELECT" -eq 2 ]]; then
                      RETURNSELECTION=1
                      clientCredentials && getOrder
                    elif [[ "$RETURNSELECT" == "q" ]]; then
                      RETURNSELECTION=1
                      exitTool
                    else
                      echo -e "\n${BOLD}${RED}ERROR${NONE}: Invalid input. Accepted inputs [ 1 | 2 | q ]."
                    fi
                done
            fi
        elif [[ "$CONFIRM" == n ]]; then
            CONFIRMCHECK=1
            getOrder
        else
            echo -e "\n${BOLD}${RED}ERROR${NONE}: Confirmation failed due to invalid input. Accepted inputs [y/n].\n"
        fi
    done
}

printFinalDate() {
    LICFILE=$(cat "$HOME/deploy/license/license.jwt")
    if [[ -f "$HOME/deploy/license/license.jwt" ]]; then
        LICINFO="$(jq -R 'split(".") | .[1] | @base64d | fromjson' <<< "$LICFILE" | awk 'NR==4' | cut -d";" -f2 | sed 's+  + +g' | sed "s+'D +' +g")"
        LICREAD=$(jq -R 'split(".") | .[1] | @base64d | fromjson' <<< "$LICFILE" | awk 'NR==4' | cut -d";" -f2 | sed 's+  + +g' | sed "s+'D +' +g" | cut -d" " -f3- | sed 's+RECREATE ++g' | sed 's/ PASSWORD=.*//')
        # printFinalDate | get the EXPIRE value
        EXPIRATION=$(echo "$LICINFO" | sed "s/.*EXPIRE='\([^']*\)'.*/\1/")
        EXPIRATION=$(date -d "$EXPIRATION" +"%d%b%Y")
        # printFinalDate | get the WARN value
        WARN=$(echo "$LICINFO" | sed "s/.*WARN=\([^ ]*\).*/\1/")
        # printFinalDate | get the GRACE value
        GRACE=$(echo "$LICINFO" | sed "s/.*GRACE=\([^ ]*\).*/\1/")
        # printFinalDate | define the sum of WARN + GRACE as EXTRATIME
        EXTRATIME=$((WARN + GRACE))
        # printFinalDate | add EXTRATIME (days) to EXPIRATION date and show FINALDATE
        FINALDATE=$(date -d "$EXPIRATION + $EXTRATIME days" +"%d%b%Y" | tr '[:lower:]' '[:upper:]')
        echo -e "\nCurrent license information:"
        echo -e "${YELLOW}----------------------------${NONE}"
        echo "$LICREAD" | sed "s/\([^ ]*=\)/\n\1/g" | sed "s+'++g" | grep -v '^OSNAME' | sed 's+=+: +g' | tail -n +2
        echo -e "${YELLOW}----------------------------${NONE}"
        echo -e "The license ultimately expires on: ${BOLD}${YELLOW}$FINALDATE${NONE}"
    fi
}

# ---------------------------------------------- terraform ----------------------------------------------

terraformClient() {
    # terraformClient | log
    echo -ne "\n$DATETIME | INFO: terraform installation procedure started." >> $LOG
    # terraformClient | pre-installation
    echo -e "Installing latest terraform..."
    cd $deploy
    loadingStart "${loadAniModern[@]}"
    # terraformClient | installation
    wget -O- https://apt.releases.hashicorp.com/gpg -q | gpg --dearmor | sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg >/dev/null 2>&1
    echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list >/dev/null 2>&1
    sudo apt update -y -qq >> $LOG 2>&1
    sudo apt install terraform -y -qq >> $LOG 2>&1
    loadingStop
    if which terraform >/dev/null 2>&1; then
        TERRAFORMCLICHECK=1
        echo -e "\n${BOLD}${GREEN}SUCCESS${NONE}: terraform $(terraform version | awk 'NR==1{print $2}') installed."
    else
        TERRAFORMCLICHECK=0
        echo -e "\n${BOLD}${RED}ERROR${NONE}: terraform installation failed. Check $LOG for details."
    fi
    echo -e "\n"
}

terraformWhichCloud() {
    if [[ "$CLOUD" == aks ]]; then
        if [[ "$TERRAFORMCLICHECK" -eq 1 ]]; then
            terraformAzureConfig
        fi
    elif [[ "$CLOUD" == eks ]]; then
        if [[ "$TERRAFORMCLICHECK" -eq 1 ]]; then
            terraformAWSConfig
        fi
    elif [[ "$CLOUD" == gke ]]; then
        if [[ "$TERRAFORMCLICHECK" -eq 1 ]]; then
            terraformGCloudConfig
        fi
    elif [[ "$CLOUD" == k8s ]]; then
        if [[ "$TERRAFORMCLICHECK" -eq 1 ]]; then
            terraformK8sConfig
        fi
    elif [[ "$CLOUD" == none ]]; then
        if [[ "$TERRAFORMCLICHECK" -eq 1 ]]; then
            echo -e "\nCloud Provider not selected. Will not download cloud provider CLI or configure Terraform."
        else
            RETURNSELECTIONTF=0
            echo -e "\n${BOLD}${RED}ERROR${NONE}: terraform is not installed.\n"
            echo -e "${BOLD}${YELLOW}----------------------------${NONE}"
            echo -e "${BOLD}${YELLOW}       INPUT REQUIRED       ${NONE}"
            echo -e "${BOLD}${YELLOW}----------------------------${NONE}"
            while [[ "$RETURNSELECTIONTF" -ne 1 ]]; do
                echo -e "Input ${BOLD}${YELLOW}1${NONE} : to re-try terraform installation."
                echo -e "Input ${BOLD}${YELLOW}q${NONE} : to exit the tool."
                echo -e "\n"
                read RETURNSELECTTF
                if [[ "$RETURNSELECTTF" -eq 1 ]]; then
                  RETURNSELECTIONTF=1
                  terraformClient
                elif [[ "$RETURNSELECT" == "q" ]]; then
                  RETURNSELECTIONTF=1
                  exitTool
                else
                  echo -e "\n${BOLD}${RED}ERROR${NONE}: Invalid input. Accepted inputs [1/q]."
                fi
            done
        fi
    fi
}

terraformAzureConfig() {
    # terraformAzureConfig | log
    echo -ne "\n$DATETIME | INFO: Azure/Terraform binding procedure started." >> $LOG
    # terraformAzureConfig | input
    while [[ -z "${AZSP}" ]]; do
      echo -e "${BOLD}${YELLOW}----------------------------${NONE}"
      echo -e "${BOLD}${YELLOW}       INPUT REQUIRED       ${NONE}"
      echo -e "${BOLD}${YELLOW}----------------------------${NONE}"
      echo -e "Input desired ServicePrincipal name to be bound to Terraform:"
      read AZSP
        if [[ -z "${AZSP}" ]]; then
          echo -e "\n${BOLD}${RED}ERROR${NONE}: Azure ServicePrincipal not set or null."
        fi
    done
    echo -e "\nCurrent Service Principal: ►►► $AZSP ◄◄◄"
    echo -e "\nLaunching ${ITALIC}az login${NONE}:"
    az login -o table --query "[].{Name:name, IsDefault:isDefault, State:state, TenantId:tenantId}"
    echo -e "\nInput the name of desired subscription (value from 1st column above):"
    read AZSUBSCRIPTION
    az account set --subscription $AZSUBSCRIPTION 
    ## set the tenant ID from a query; validate
    TF_VAR_tenant_id=$(az account show --query 'tenantId' --output tsv)
    export TF_VAR_tenant_id
    ## set the subscription Name from a query; validate
    TF_VAR_subscription_name=$(az account show --query 'name' --output tsv)
    export TF_VAR_subscription_name
    ## set the subscription ID from a query; validate
    TF_VAR_subscription_id=$(az account show --query 'id' --output tsv)
    export TF_VAR_subscription_id
    ## obtain a client secret
    TF_VAR_client_secret=$(az ad sp create-for-rbac --skip-assignment --name "$AZSP" --query password --output tsv --only-show-errors 2> /dev/null)
    export TF_VAR_client_secret
    ## obtain the client ID
    TF_VAR_client_id=$(az ad sp list --display-name "$AZSP" --query "[0].appId" | sed -e 's/^"//' -e 's/"$//')
    export TF_VAR_client_id
    # write values to .terraform.env
    echo -e "TF_VAR_tenant_id=$TF_VAR_tenant_id\nTF_VAR_subscription_name=$TF_VAR_subscription_name\nTF_VAR_subscription_id=$TF_VAR_subscription_id\nTF_VAR_client_secret=$TF_VAR_client_secret\nTF_VAR_client_id=$TF_VAR_client_id" > $HOME/.terraform.env
    # show information
    echo -e "Azure/Terraform binding information:\n"
    echo -e "${BOLD}${YELLOW}---------------------------------------------------------${NONE}"
    echo -e "Tenant ID:       $TF_VAR_tenant_id"
    echo -e "Subscription:    $TF_VAR_subscription_name"
    echo -e "Subscription ID: $TF_VAR_subscription_id"
    echo -e "ClientID:        $TF_VAR_client_id"
    echo -e "ClientSecret:    $TF_VAR_client_secret"
    echo -e "${BOLD}${YELLOW}---------------------------------------------------------${NONE}"
    ## sourcing terraform vars in ~/.bashrc
    if [[ -s $HOME/.terraform.env ]]; then
      echo -e "\nsource ~/.terraform.env" >> $HOME/.bashrc && source $HOME/.bashrc
      echo -e "\n${BOLD}${GREEN}SUCCESS${NONE}: Variables saved in ~/.terraform.env. File sourced in ~/.bashrc"
    else
      TFENVCHECK=0
      echo -e "${BOLD}${YELLOW}----------------------------${NONE}"
      echo -e "${BOLD}${YELLOW}     ATTENTION REQUIRED     ${NONE}"
      echo -e "${BOLD}${YELLOW}----------------------------${NONE}"
      echo -e "\n${BOLD}${RED}ERROR${NONE}: ~/.terraform.env could not be created.\n"
      echo -e "\nManually create the ~/.terraform.env file and add the following lines in it.\n"
      echo -e "TF_VAR_tenant_id=$TF_VAR_tenant_id"
      echo -e "TF_VAR_subscription_name=$TF_VAR_subscription_name"
      echo -e "TF_VAR_subscription_id=$TF_VAR_subscription_id"
      echo -e "TF_VAR_client_secret=$TF_VAR_client_secret"
      echo -e "TF_VAR_client_id=$TF_VAR_client_id"
      while [[ "$TFENVCHECK" -eq 0 ]];do
        echo -e "Input ${BOLD}${YELLOW}1${NONE} : after manually adding the above into ~/.terraform.env."
        echo -e "Input ${BOLD}${YELLOW}q${NONE} : to exit the tool."
        echo -e "\n"
        read AZTFPROCEED
        if [[ "$AZTFPROCEED" -eq 1 ]]; then
          TFENVCHECK=1
        elif [[ "$AZTFPROCEED" == "q" ]]; then
          TFENVCHECK=1
          sed -i '+source ~/.terraform.env+d' $HOME/.bashrc
          rm -f $HOME/.terraform.env
          exitTool
        else
          echo -e "\n${BOLD}${RED}ERROR${NONE}: Invalid input. Accepted inputs [1/q]."
        fi
      done
    fi
    echo -e "\nCloning viya4-iac-azure repository from https://github.com/sassoftware/viya4-iac-azure..."
    IACDESTINATION="$HOME/deploy/viya4-iac-azure"
    git clone https://github.com/sassoftware/viya4-iac-azure $IACDESTINATION >> $LOG 2>&1
    if [ -d "$IACDESTINATION" ] && [ "$(ls -A "$IACDESTINATION")" ]; then
      echo -e "\n${BOLD}${GREEN}SUCCESS${NONE}: Repository cloned in $HOME/deploy/viya4-iac-azure."
      echo -e "\nValidating Terraform..."
      loadingStart "${loadAniModern[@]}"
      cd $IACDESTINATION
      terraform init >> $LOG 2>&1
      if terraform validate -json | grep -q '"valid": true,' && ! terraform validate -json | grep -q '"valid": false,'; then
          loadingStop
          echo -e "\n${BOLD}${GREEN}SUCCESS${NONE}: Azure/Terraform binding succeeded."
      fi
      loadingStop
    else
      AZTFCHECK=0
      unset AZSP AZSUBSCRIPTION
      echo -e "\n${BOLD}${RED}ERROR${NONE}: Azure/Terraform binding failed.\n"
      echo -e "${BOLD}${YELLOW}----------------------------${NONE}"
      echo -e "${BOLD}${YELLOW}       INPUT REQUIRED       ${NONE}"
      echo -e "${BOLD}${YELLOW}----------------------------${NONE}"
      while [[ "$AZTFCHECK" -eq 0 ]]; do
        echo -e "Input ${BOLD}${YELLOW}1${NONE} : to re-try Azure/Terraform binding."
        echo -e "Input ${BOLD}${YELLOW}q${NONE} : to exit the tool."
        echo -e "\n"
        read AZTFRETRY
        if [[ "$AZTFRETRY" -eq 1 ]]; then
          AZTFCHECK=1
          terraformAzureConfig
        elif [[ "$AZTFRETRY" == "q" ]]; then
          AZTFCHECK=1
          echo -e "\nRemoving source to ~/.terraform.env from ~/.bashrc..."
          sed -i '+source ~/.terraform.env+d' $HOME/.bashrc
          echo -e "\nSource to ~/.terraform.env removed from ~/.bashrc"
          echo -e "\nDeleting the ~/.terraform.env file..."
          rm -f $HOME/.terraform.env
          echo -e "\n~/.terraform.env file deleted."
          exitTool
        else
          echo -e "\n${BOLD}${RED}ERROR${NONE}: Invalid input. Accepted inputs [1/q]."
        fi
      done
    fi
}

terraformAWSConfig() {
    # terraformAWSConfig | log
    echo -ne "\n$DATETIME | INFO: AWS/Terraform binding procedure started." >> $LOG
    # terraformAWSConfig | input / credentials
    echo -e "${BOLD}${YELLOW}----------------------------${NONE}"
    echo -e "${BOLD}${YELLOW}       INPUT REQUIRED       ${NONE}"
    echo -e "${BOLD}${YELLOW}----------------------------${NONE}"
    # terraformAWSConfig | check if file ~/.aws/credentials exists, check if it contains aws_access_key_id / aws_access_access_key. if it does, source the file. otherwise, ask for user input.
    if [[ -s $HOME/.aws/credentials ]]; then
      if grep -q -E "^aws_access_key_id=|aws_secret_access_key=" $HOME/.aws/credentials; then
        AWSCREDEX=1
      fi
    elif ( [[ -n "$aws_access_key_id" ]] && [[ -n "$aws_secret_access_key" ]] ) || ( [[ -n "$TF_VAR_aws_access_key_id" ]] && [[ -n "$TF_VAR_aws_secret_access_key" ]] ); then
      AWSCREDEX=1
    else
      echo -e "\nAWS Credentials not found."
      AWSCREDEX=0
      while [[ "$AWSCREDEX" -eq 0 ]]; do
        echo -e "\nLaunching ${ITALIC}aws configure${NONE}:"
        aws configure
        if [[ -s $HOME/.aws/credentials ]] && [[ -s $HOME/.aws/config ]]; then
          AWSCREDEX=1
          echo -e "\n${BOLD}${GREEN}SUCCESS${NONE}: aws-cli stored your Access key and secret in $HOME/.aws/credentials."
        else
          AWSCREDEX=0
          unset AZSP AZSUBSCRIPTION
          echo -e "\n${BOLD}${RED}ERROR${NONE}: AWS did not store your credentials in $HOME/.aws/credentials."
          echo -e "${BOLD}${YELLOW}----------------------------${NONE}"
          echo -e "${BOLD}${YELLOW}       INPUT REQUIRED       ${NONE}"
          echo -e "${BOLD}${YELLOW}----------------------------${NONE}"
          while [[ "$AWSCREDEX" -eq 0 ]]; do
            echo -e "Input ${BOLD}${YELLOW}1${NONE} : to re-try aws configure."
            echo -e "Input ${BOLD}${YELLOW}q${NONE} : to exit the tool."
            echo -e "\n"
            read AWSRETRY
            if [[ "$AWSRETRY" -eq 1 ]]; then
              AWSCREDEX=0
            elif [[ "$AWSRETRY" == "q" ]]; then
              AWSCREDEX=0
              rm -f $HOME/.aws/credentials
              exitTool
            else
              echo -e "\n${BOLD}${RED}ERROR${NONE}: Invalid input. Accepted inputs [1/q]."
            fi
          done
        fi
      done
      echo -e "\nCloning viya4-iac-aws repository from https://github.com/sassoftware/viya4-iac-aws..."
      IACDESTINATION="$HOME/deploy/viya4-iac-aws"
      git clone https://github.com/sassoftware/viya4-iac-aws $IACDESTINATION >> $LOG 2>&1
      if [ -d "$IACDESTINATION" ] && [ "$(ls -A "$IACDESTINATION")" ]; then
        echo -e "\n${BOLD}${GREEN}SUCCESS${NONE}: Repository cloned in $HOME/deploy/viya4-iac-aws."
        echo -e "\nValidating Terraform..."
        loadingStart "${loadAniModern[@]}"
        cd $IACDESTINATION
        terraform init >> $LOG 2>&1
        if terraform validate -json | grep -q '"valid": true,' && ! terraform validate -json | grep -q '"valid": false,'; then
            loadingStop
            echo -e "\n${BOLD}${GREEN}SUCCESS${NONE}: AWS/Terraform binding succeeded."  
        else
          loadingStop
          AWSTFCHECK=0
          echo -e "\n${BOLD}${RED}ERROR${NONE}: AWS/Terraform binding failed.\n"
          echo -e "${BOLD}${YELLOW}----------------------------${NONE}"
          echo -e "${BOLD}${YELLOW}       INPUT REQUIRED       ${NONE}"
          echo -e "${BOLD}${YELLOW}----------------------------${NONE}"
          while [[ "$AWSTFCHECK" -eq 0 ]]; do
            echo -e "Input ${BOLD}${YELLOW}1${NONE} : to re-try AWS/Terraform binding."
            echo -e "Input ${BOLD}${YELLOW}q${NONE} : to exit the tool."
            echo -e "\n"
            read AWSTFRETRY
            if [[ "$AWSTFRETRY" -eq 1 ]]; then
              AWSTFCHECK=1
              terraformAWSConfig
            elif [[ "$AWSTFRETRY" == "q" ]]; then
              AWSTFCHECK=1
              exitTool
            else
              echo -e "\n${BOLD}${RED}ERROR${NONE}: Invalid input. Accepted inputs [1/q]."
            fi
          done  
        fi
      fi
    fi   
}

terraformGCloudConfig() {
    # terraformGCloudConfig | log
    echo -ne "\n$DATETIME | INFO: GCP/Terraform binding procedure started." >> $LOG
    # terraformGCloudConfig | input / credentials
    echo -e "${BOLD}${YELLOW}----------------------------${NONE}"
    echo -e "${BOLD}${YELLOW}       INPUT REQUIRED       ${NONE}"
    echo -e "${BOLD}${YELLOW}----------------------------${NONE}"
    echo -e "Create a new GCP Service Account or use an existing one?"
    GCPSACHOICE=0
    while [[ "$GCPSACHOICE" -eq 0 ]]; do
        echo -e "Input ${BOLD}${YELLOW}1${NONE} : to create a new GCP Service Account (Recommended)."
        echo -e "Input ${BOLD}${YELLOW}2${NONE} : to select an existing GCP Service Account."
        echo -e "Input ${BOLD}${YELLOW}q${NONE} : to exit the tool."
        echo -e "\n"
        read GCPSASELECT
        if [[ "$GCPSASELECT" -eq 1 ]]; then
            while [[ -z "${GCPSA}" ]]; do
                echo -e "Input desired Service Account name for Terraform:"
                read GCPSA
                if [[ -z "${GCPSA}" ]]; then
                    echo -e "\n${BOLD}${RED}ERROR${NONE}: Service Account name not set or null."
                else
                    GCPSACHOICE=1
                fi
            done    
        elif [[ "$GCPSASELECT" -eq 2 ]]; then
            while [[ -z "${GCPSA}" ]]; do
                if gcloud auth list 2>&1 | grep -q "ACTIVE"; then
                    echo -e "\n"
                    gcloud projects list --format="table(project_id)" | tail -n +2 | xargs -I {} sh -c 'echo -n "Project: {} | Email: "; gcloud iam service-accounts list --project {} --format="table(email)" | tail -n +2' | awk '{$1=$1};1'
                    echo -e "\nInput existing Service Account name for Terraform to use:"
                    read GCPSA
                    if [[ -z "${GCPSA}" ]]; then
                        echo -e "\n${BOLD}${RED}ERROR${NONE}: Service Account name not set or null."
                    else
                        GCPSACHOICE=1
                        GCPSAEXISTENT=1
                    fi
                else
                    echo -e "\nLaunching ${ITALIC}gcloud auth init${NONE}:"
                    echo -e "\n"
                    gcloud auth login --quiet
                    gcloud projects list --format="table(project_id)" | tail -n +2 | xargs -I {} sh -c 'echo -n "Project: {} | Email: "; gcloud iam service-accounts list --project {} --format="table(email)" | tail -n +2' | awk '{$1=$1};1'
                    echo -e "\nInput existing Service Account name for Terraform to use ${BOLD}${YELLOW}(Only the name before '@' in Email)${NONE}:"
                    read GCPSA
                    if [[ -z "${GCPSA}" ]]; then
                        echo -e "\n${BOLD}${RED}ERROR${NONE}: Service Account name not set or null."
                    else
                        GCPSACHOICE=1
                    fi
                fi
            done
        elif [[ "$GCPSASELECT" -eq q ]]; then
            GCPSACHOICE=1
            exitTool
        else
            echo -e "\n${BOLD}${RED}ERROR${NONE}: Invalid input. Accepted inputs [ 1 | 2 | q ]."
        fi
    done
    echo -e "\nCurrent Service Principal: ►►► $GCPSA ◄◄◄"
    if gcloud auth list 2>&1 | grep -q "ACTIVE"; then
        echo -e "gcloud cli session already active" >> $LOG
    else
        echo -e "\nLaunching ${ITALIC}gcloud auth init${NONE}:"
        gcloud auth login --quiet
    fi
    echo -e "\n"
    gcloud projects list --format="table(project_id,name,project_number)"
    echo -e "\nInput the project-id of desired project (value from 1st column above):"
    read GCPPROJECTID
    gcloud config set project $GCPPROJECTID >> $LOG 2>&1
    echo -e "Current Project: ►►► $GCPPROJECTID ◄◄◄"
    # create service account
    if [ -z "${GCPSAEXISTENT}" ]; then
        echo -e "\nCreating Service Account $GCPSA and granting necessary Roles to for $GCPPROJECTID..."
        gcloud iam service-accounts create $GCPSA --description "Service Account for Terraform viya4-iac-gcp" --display-name "$GCPSA" >> $LOG 2>&1
    else
        echo -e "\nGranting necessary Roles to Service Account $GCPSA for $GCPPROJECTID..."
    fi
    loadingStart "${loadAniModern[@]}"
    # grant roles
    gcloud projects add-iam-policy-binding $GCPPROJECTID --member serviceAccount:${GCPSA}@${GCPPROJECTID}.iam.gserviceaccount.com --role roles/cloudsql.admin >> $LOG 2>&1
    gcloud projects add-iam-policy-binding $GCPPROJECTID --member serviceAccount:${GCPSA}@${GCPPROJECTID}.iam.gserviceaccount.com --role roles/compute.admin >> $LOG 2>&1
    gcloud projects add-iam-policy-binding $GCPPROJECTID --member serviceAccount:${GCPSA}@${GCPPROJECTID}.iam.gserviceaccount.com --role roles/compute.networkAdmin >> $LOG 2>&1
    gcloud projects add-iam-policy-binding $GCPPROJECTID --member serviceAccount:${GCPSA}@${GCPPROJECTID}.iam.gserviceaccount.com --role roles/compute.securityAdmin >> $LOG 2>&1
    gcloud projects add-iam-policy-binding $GCPPROJECTID --member serviceAccount:${GCPSA}@${GCPPROJECTID}.iam.gserviceaccount.com --role roles/compute.viewer >> $LOG 2>&1
    gcloud projects add-iam-policy-binding $GCPPROJECTID --member serviceAccount:${GCPSA}@${GCPPROJECTID}.iam.gserviceaccount.com --role roles/container.admin >> $LOG 2>&1
    gcloud projects add-iam-policy-binding $GCPPROJECTID --member serviceAccount:${GCPSA}@${GCPPROJECTID}.iam.gserviceaccount.com --role roles/container.clusterAdmin >> $LOG 2>&1
    gcloud projects add-iam-policy-binding $GCPPROJECTID --member serviceAccount:${GCPSA}@${GCPPROJECTID}.iam.gserviceaccount.com --role roles/container.developer >> $LOG 2>&1
    gcloud projects add-iam-policy-binding $GCPPROJECTID --member serviceAccount:${GCPSA}@${GCPPROJECTID}.iam.gserviceaccount.com --role roles/file.editor >> $LOG 2>&1
    gcloud projects add-iam-policy-binding $GCPPROJECTID --member serviceAccount:${GCPSA}@${GCPPROJECTID}.iam.gserviceaccount.com --role roles/iam.serviceAccountAdmin >> $LOG 2>&1
    gcloud projects add-iam-policy-binding $GCPPROJECTID --member serviceAccount:${GCPSA}@${GCPPROJECTID}.iam.gserviceaccount.com --role roles/iam.serviceAccountUser >> $LOG 2>&1
    gcloud projects add-iam-policy-binding $GCPPROJECTID --member serviceAccount:${GCPSA}@${GCPPROJECTID}.iam.gserviceaccount.com --role roles/resourcemanager.projectIamAdmin >> $LOG 2>&1
    # export service account keyfile
    GCPSA_KEY_FILE="$HOME/.viya4-tf-gcp-service-account.json"
    gcloud iam service-accounts keys create ${GCPSA_KEY_FILE} --iam-account ${GCPSA}@${GCPPROJECTID}.iam.gserviceaccount.com >> $LOG 2>&1
    loadingStop
    echo -e "\nThe following Roles were granted to $GCPSA for $GCPPROJECTID:"
    echo -e "${BOLD}${YELLOW}-------------------------------------${NONE}"
    gcloud projects get-iam-policy $GCPPROJECTID --flatten="bindings[].members" --format='table(bindings.role)' --filter="bindings.members:$GCPSA" | grep -v ROLE | sort -u
    echo -e "${BOLD}${YELLOW}-------------------------------------${NONE}"
    if [[ -s $GCPSA_KEY_FILE ]]; then
        echo -e "\n${BOLD}${GREEN}SUCCESS${NONE}: gcp-cli service account key file stored in $GCPSA_KEY_FILE."
    fi
    echo -e "\nCloning viya4-iac-gcp repository from https://github.com/sassoftware/viya4-iac-gcp..."
    IACDESTINATION="$HOME/deploy/viya4-iac-gcp"
    git clone https://github.com/sassoftware/viya4-iac-gcp $IACDESTINATION >> $LOG 2>&1
    if [ -d "$IACDESTINATION" ] && [ "$(ls -A "$IACDESTINATION")" ]; then
      echo -e "\n${BOLD}${GREEN}SUCCESS${NONE}: Repository cloned in $HOME/deploy/viya4-iac-gcp."
      echo -e "\nValidating Terraform..."
      loadingStart "${loadAniModern[@]}"
      cd $IACDESTINATION
      terraform init >> $LOG 2>&1
      if terraform validate -json | grep -q '"valid": true,' && ! terraform validate -json | grep -q '"valid": false,'; then
          loadingStop
          echo -e "\n${BOLD}${GREEN}SUCCESS${NONE}: GCP/Terraform binding succeeded."  
      else
        loadingStop
        GCPTFCHECK=0
        echo -e "\n${BOLD}${RED}ERROR${NONE}: GCP/Terraform binding failed.\n"
        echo -e "${BOLD}${YELLOW}----------------------------${NONE}"
        echo -e "${BOLD}${YELLOW}       INPUT REQUIRED       ${NONE}"
        echo -e "${BOLD}${YELLOW}----------------------------${NONE}"
        while [[ "$GCPTFCHECK" -eq 0 ]]; do
          echo -e "Input ${BOLD}${YELLOW}1${NONE} : to re-try GCP/Terraform binding."
          echo -e "Input ${BOLD}${YELLOW}q${NONE} : to exit the tool."
          echo -e "\n"
          read GCPTFRETRY
          if [[ "$GCPTFRETRY" -eq 1 ]]; then
            GCPTFCHECK=1
            terraformGCloudConfig
          elif [[ "$GCPTFRETRY" == "q" ]]; then
            GCPTFCHECK=1
            exitTool
          else
            echo -e "\n${BOLD}${RED}ERROR${NONE}: Invalid input. Accepted inputs [1/q]."
          fi
        done  
      fi
    fi
}

terraformK8sConfig() {
    # terraformK8sConfig | clone repo
    echo -e "Cloning viya4-iac-k8s repository from https://github.com/sassoftware/viya4-iac-k8s..."
    IACDESTINATION="$HOME/deploy/viya4-iac-k8s"
    loadingStart "${loadAniModern[@]}"
    git clone https://github.com/sassoftware/viya4-iac-k8s $IACDESTINATION >> $LOG 2>&1
    if [ -d "$IACDESTINATION" ] && [ "$(ls -A "$IACDESTINATION")" ]; then
        loadingStop
        echo -e "\n${BOLD}${GREEN}SUCCESS${NONE}: Repository cloned in $HOME/deploy/viya4-iac-k8s."
        echo -e "\n${BOLD}${YELLOW}INFO${NONE}: Navigate to ${ITALIC}${CYAN}https://github.com/sassoftware/viya4-iac-k8s#customize-input-values${NONE} and follow the steps from ${BOLD}${YELLOW}Customize Input Values${NONE}"
    else
        IACK8S=0
        echo -e "\n${BOLD}${RED}ERROR${NONE}: Repository could not be cloned.\n"
        echo -e "${BOLD}${YELLOW}----------------------------${NONE}"
        echo -e "${BOLD}${YELLOW}       INPUT REQUIRED       ${NONE}"
        echo -e "${BOLD}${YELLOW}----------------------------${NONE}"
        while [[ "$IACK8S" -eq 0 ]]; do
          echo -e "Input ${BOLD}${YELLOW}1${NONE} : to re-try cloning."
          echo -e "Input ${BOLD}${YELLOW}q${NONE} : to exit the tool."
          echo -e "\n"
          read IACK8SRETRY
          if [[ "$IACK8SRETRY" -eq 1 ]]; then
            IACK8S=1
            terraformK8sConfig
          elif [[ "$IACK8SRETRY" == "q" ]]; then
            IACK8S=1
            exitTool
          else
            echo -e "\n${BOLD}${RED}ERROR${NONE}: Invalid input. Accepted inputs [1/q]."
          fi
        done  
    fi
}

# ---------------------------------------------- modes ----------------------------------------------

clientsOnlyMode() {
    clear
    requiredPackages
    requiredClients
    if [[ "$CLOUD" == aks ]]; then
        echo "Sleeping for 5 seconds to allow you a check."
        sleep 5
        az-cli
    elif [[ "$CLOUD" == eks ]]; then
        echo "Sleeping for 5 seconds to allow you a check."
        sleep 5
        aws-cli
    elif [[ "$CLOUD" == gke ]]; then
        echo "Sleeping for 5 seconds to allow you a check."
        sleep 5
        gcloud-cli
    elif [[ "$CLOUD" == none ]]; then
        echo -e "\nCloud Provider not selected. Will not download cloud provider CLI."
        echo "Sleeping for 5 seconds to allow you a check."
        sleep 5
    fi
    if [[ "$MODESELECTED" == "clientsOnlyMode" ]]; then
        exitTool
    fi
}

orderOnlyMode() {
    clear
    viya4OrdersCli
    getOrder
    if [[ "$MODESELECTED" == "orderOnlyMode" ]]; then
        exitTool
    fi
    rm -f $HOME/.viya4-orders-cli
}

tfOnlyMode() {
    clear
    if [[ "$CLOUD" == aks ]]; then
        if which az >/dev/null 2>&1; then
            echo -e "azure-cli already installed." >> $LOG 2>&1
        else
            az-cli
        fi
    elif [[ "$CLOUD" == eks ]]; then
        if which aws >/dev/null 2>&1; then
            echo -e "aws-cli already installed." >> $LOG 2>&1
        else
            aws-cli
        fi
    elif [[ "$CLOUD" == gke ]]; then
        if which gcloud >/dev/null 2>&1; then
            echo -e "azure-cli already installed." >> $LOG 2>&1
        else
            gcloud-cli
        fi
    elif [[ "$CLOUD" == k8s ]]; then
        if which ansible >/dev/null && which ansible >/dev/null; then
            echo -e "docker and ansible already installed." >> $LOG 2>&1
        else
            k8s
        fi
    elif [[ "$CLOUD" == none ]]; then
        CPSELECT=0
        echo -e "\n${BOLD}${RED}ERROR${NONE}: Cloud Provider not selected. A Cloud Provider must be selected."
        echo -e "${BOLD}${YELLOW}----------------------------${NONE}"
        echo -e "${BOLD}${YELLOW}       INPUT REQUIRED       ${NONE}"
        echo -e "${BOLD}${YELLOW}----------------------------${NONE}"
        while [[ "$CPSELECT" -eq 0 ]]; do
        echo -e "Input ${BOLD}${YELLOW}1${NONE} : to return to Cloud Provider Selection Menu."
        echo -e "Input ${BOLD}${YELLOW}q${NONE} : to exit the tool."
        echo -e "\n"
        read CPSELECTION
        if [[ "$CPSELECTION" -eq 1 ]]; then
          CPSELECT=1
          providerMenu
        elif [[ "$CPSELECTION" == "q" ]]; then
          CPSELECT=1
          exitTool
        else
          echo -e "\n${BOLD}${RED}ERROR${NONE}: Invalid input. Accepted inputs [1/q]."
        fi
        done
    fi
    terraformClient
    terraformWhichCloud
    if [[ "$MODESELECTED" == "tfOnlyMode" ]]; then
        exitTool
    fi
}

defaultMode() {
    clear
    clientsOnlyMode
    orderOnlyMode
    if [[ "$MODESELECTED" == "defaultMode" ]]; then
        exitTool
    fi
}

fullMode() {
    defaultMode
    PROCEEDCONF=0
    while [[ "$PROCEEDCONF" -eq 0 ]]; do
        echo -e "\nPausing for you to check the license information above."
        echo -e "Proceed with Terraform configuration? [y/n]"
        read PROCEEDCONFIRM
        if [[ "$PROCEEDCONFIRM" == y ]]; then
            PROCEEDCONF=1
        elif [[ "$PROCEEDCONFIRM" == n ]]; then
            PROCEEDCONF=0
            echo -e "Sleeping for 10 seconds before asking again."
            sleep 10
        else
            echo -e "\n${BOLD}${RED}ERROR${NONE}: Invalid input. Accepted inputs [y/n]."
        fi
    done
    tfOnlyMode
    if [[ "$MODESELECTED" == "fullMode" ]]; then
        exitTool
    fi
}

# --------------------------------------------  startScript  --------------------------------------------

providerMenu

# ---------------------------------------------  scriptEnd  ---------------------------------------------