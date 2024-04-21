#!/bin/bash

# -------------------------------------------------  header  --------------------------------------------------

# SAS Viya Initializaton Tool
# Description: the script can fully prepare a bastion host for a SAS Viya 4 cluster creation and management on Azure, AWS and Google Cloud Plaform.

# Copyright © 2023, SAS Institute Inc., Cary, NC, USA. All Rights Reserved.
# SPDX-License-Identifier: Apache-2.0

# --------------------------------------------------  info  ---------------------------------------------------

V4ITVER="v1.0.9"                # viya4-init-tool version
VERDATE="April 21st, 2024"      # viya4-init-tool version date
LSVIYASTABLE="2024.04"          # latest SAS Viya Stable supported version by tool
ESVIYASTABLE="2024.01"          # earliest SAS Viya Stable supported version by tool
LSVIYALTS="2023.10"             # latest SAS Viya LTS supported version by tool
ESVIYALTS="2022.09"             # earliest SAS Viya LTS supported version by tool

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
echo -ne "\n$DATETIME | ${INFOMSG} | Tool inizialized." >> $LOG
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

# textStyle | mixed
BBLACK='\033[1;30m'  # Black
BRED='\033[1;31m'    # Red
BGREEN='\033[1;32m'  # Green
BYELLOW='\033[1;33m' # Yellow
BBLUE='\033[1;34m'   # Blue
BPURPLE='\033[1;35m' # Purple
BCYAN='\033[1;36m'   # Cyan
BWHITE='\033[1;37m'  # White

# textStyle | messages
INFOMSG="${BCYAN}INFO${NONE}"
WARNMSG="${BYELLOW}WARN${NONE}"
ERRORMSG="${BRED}ERROR${NONE}"
SUCCESSMSG="${BGREEN}SUCCESS${NONE}"

# ---------------------------------------------- mainScript ----------------------------------------------

# -------------------------------------------  selectionMenus  -------------------------------------------

providerMenu(){
clear
    echo -e "${CYAN}__________________________________________________${NONE}"
    echo -e "\n            ${BCYAN}SAS Viya${NONE} ${BOLD}Initialization Tool${NONE}"
    echo -e "${CYAN}__________________________________________________${NONE}"
    echo -e "\n          ${BOLD}| Provider Selection Menu |${NONE}"
    echo -e "\nInput ${BCYAN}1${NONE} : for Microsoft Azure (AKS)"
    echo -e "Input ${BCYAN}2${NONE} : for Amazon Web Services (EKS)"
    echo -e "Input ${BCYAN}3${NONE} : for Google Cloud Plaform (GKE)"
    echo -e "Input ${BCYAN}4${NONE} : for Open Source Kubernetes (K8s)"
    echo -e "Input ${BYELLOW}s${NONE} : to skip this menu"
    echo -e "Input ${BRED}q${NONE} : to exit the tool\n"

    read CLOUDOPT
    while [[ "$CLOUDOPT" -ne 1 ]] && [[ "$CLOUDOPT" -ne 2 ]] && [[ "$CLOUDOPT" -ne 3 ]] && [[ "$CLOUDOPT" -ne 4 ]] && [[ "$CLOUDOPT" != "s" ]] && [[ "$CLOUDOPT" != "q" ]]; do
        clear
        providerMenu
    done
    CLOUDCHECK=0
    case "$CLOUDOPT" in
        "1") while [[ "$CLOUDCHECK" -eq 0 ]]; do
                MICROSOFTAZURE="${BCYAN}Microsoft Azure (AKS)${NONE}"
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
                    echo -e "\n${ERRORMSG} | Invalid input. Accepted inputs [y/n]."
            
                fi
             done;;
        "2") while [[ "$CLOUDCHECK" -eq 0 ]]; do
                AMAZONAWS="${BYELLOW}Amazon Web Services (EKS)${NONE}"
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
                    echo -e "\n${ERRORMSG} | Invalid input. Accepted inputs [y/n]."
            
                fi
             done;;
        "3") while [[ "$CLOUDCHECK" -eq 0 ]]; do
                GOOGLEGCP="${BRED}Google Cloud Provider (GKE)${NONE}"
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
                    echo -e "\n${ERRORMSG} | Invalid input. Accepted inputs [y/n]."
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
                    echo -e "\n${ERRORMSG} | Invalid input. Accepted inputs [y/n]."
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
    echo -e "\n            ${BCYAN}SAS Viya${NONE} ${BOLD}Initialization Tool${NONE}"
    echo -e "${CYAN}__________________________________________________${NONE}"
    echo -e "\n             ${BOLD}| Mode Selection Menu |${NONE}"
    echo -e "\n${BCYAN}default${NONE}:"
    echo -e "- Installs required packages and clients"
    echo -e "- Installs provider CLI (if defined)"
    echo -e "- Downloads order assets, license and certificates"
    echo -e "\n${BCYAN}full${NONE}:"
    echo -e "- What default does"
    echo -e "- Installs Terraform and configures it"
    echo -e "- Downloads latest viya4-IaC"
    echo -e "\n${BCYAN}clients-only${NONE}:"
    echo -e "- Installs required packages and clients"
    echo -e "- Installs provider CLI (if defined)"
    echo -e "\n${BCYAN}order-only${NONE}:"
    echo -e "- Downloads order assets, license and certificates"
    echo -e "\n${BCYAN}tf-only${NONE} (if Provider is defined):"
    echo -e "- Installs provider CLI"
    echo -e "- Installs Terraform and configures it"
    echo -e "- Downloads latest viya4-IaC\n"
    echo -e "\n       Provider: $CLOUDNAME"
    echo -e "\n${CYAN}__________________________________________________${NONE}"
    echo -e "\nInput ${BCYAN}1${NONE} : for default mode "
    echo -e "Input ${BCYAN}2${NONE} : for full mode"
    echo -e "Input ${BCYAN}3${NONE} : for clients-only mode"
    echo -e "Input ${BCYAN}4${NONE} : for order-only mode"
    echo -e "Input ${BCYAN}5${NONE} : for tf-only mode"
    echo -e "Input ${BYELLOW}r${NONE} : to return to previous menu"
    echo -e "Input ${BRED}q${NONE} : to exit the tool\n"
    
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
                    echo -e "\n${ERRORMSG} | Invalid input. Accepted inputs [y/n]."
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
                    echo -e "\n${ERRORMSG} | Invalid input. Accepted inputs [y/n]."
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
                    echo -e "\n${ERRORMSG} | Invalid input. Accepted inputs [y/n]."
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
                    echo -e "\n${ERRORMSG} | Invalid input. Accepted inputs [y/n]."
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
                    echo -e "\n${ERRORMSG} | Invalid input. Accepted inputs [y/n]."
                fi
             done;;
        "r") providerMenu;;
        "q") exitTool;;
    esac
}

exitTool() {
    echo -ne "\n$DATETIME | ${INFOMSG} | Tool execution completed." >> $LOG
    echo -e "\nThank you for using this tool.\n"
    exit 0
}

# -------------------------------------------  requirements  -------------------------------------------
requiredPackages() {
    # requiredPackages | log
    echo -ne "\n$DATETIME | ${INFOMSG} | Required packages installation procedure started." >> $LOG
    # requiredPackages | pre-installation
    cd $deploy
    echo -ne "Installing required packages. This might take a minute or two...\n"
    loadingStart "${loadAniModern[@]}"
    requiredPackages=("zsh" "zip" "unzip" "git" "mlocate" "jq" "bat" "python3" "python3-pip")
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
    # requiredPackages | clone pyviyatools & viya4-ark
    mkdir $HOME/$VIYA_NS/viya-utils && cd $HOME/$VIYA_NS/viya-utils
    git clone https://github.com/sassoftware/pyviyatools >> $LOG 2>&1
    git clone https://github.com/sassoftware/viya4-ark >> $LOG 2>&1
    cd $deploy
    # requiredPackages | post-installation & check if all required packages were installed
    loadingStop
    not_installed=()
    for package in "${requiredPackages[@]}"; do
    if [[ ! $(dpkg -s "$package" >> $LOG 2>&1) ]]; then
        not_installed+=("$package")
    fi
    done
    if [ ${#not_installed[@]} -eq 0 ]; then
      echo -ne "\n${ERRORMSG} | ${not_installed[@]} failed to install. Check $LOG for details."
    else
      echo -ne "\n${SUCCESSMSG} | All required packages installed."
    fi
    echo -e "\n"
}

# -----------------------------------------  cloudProviderCLIs  ----------------------------------------

az-cli() {
    # az-cli | log
    echo -ne "\n$DATETIME | ${INFOMSG} | azure-cli nstallation procedure started." >> $LOG
    # az-cli | pre-installation
    cd $deploy
    echo -ne "Installing latest ${CYAN}azure-cli${NONE}..."
    loadingStart "${loadAniModern[@]}"
    # az-cli | installation
    echo -ne "\n$DATETIME | ${INFOMSG} | Downloading https://aka.ms/InstallAzureCLIDeb and executing." >> $LOG 2>&1
    curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash >> $LOG 2>&1
    # az-cli | post-installation & check if all required packages were installed
    loadingStop
    if which az >/dev/null 2>&1; then
        echo -ne "\n${SUCCESSMSG} | azure-cli $(az version -o yaml | awk 'NR==1{print $2}') installed."
    else
        echo -ne "\n${ERRORMSG} | azure-cli installation failed. Check $LOG for details."
    fi
    echo -e "\n"
}

aws-cli() {
    # aws-cli | log
    echo -ne "\n$DATETIME | ${INFOMSG} | aws-cli installation procedure started." >> $LOG
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
        echo -ne "\n${SUCCESSMSG} | aws-cli v$(aws --version | awk 'NR==1{print $1}' | cut -d"/" -f2) installed."
    else
        echo -ne "\n${ERRORMSG} | aws-cli installation failed. Check $LOG for details."
    fi
    echo -e "\n"
}

gcloud-cli() {
    # gcloud-cli | log
    echo -ne "\n$DATETIME | ${INFOMSG} | gcloud-cli installation procedure started." >> $LOG
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
        echo -ne "\n${SUCCESSMSG} | gcloud-cli v$(gcloud version | awk 'NR==1{print $4}') installed."
    else
        echo -ne "\n${ERRORMSG} | gcloud-cli installation failed. Check $LOG for details."
    fi
    echo -e "\n"
}

k8s() {
    # k8s | log
    echo -ne "\n$DATETIME | ${INFOMSG} | ansible and docker installation procedure started." >> $LOG
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
        echo -ne "\n${SUCCESSMSG} | docker $(docker --version | cut -d" " -f3 | cut -d"," -f1) installed."
    else
        echo -ne "\n${ERRORMSG} | docker installation failed. Check $LOG for details."
    fi
    # k8s | ansible installation
    echo -e "\nInstalling latest ansible-core..."
    loadingStart "${loadAniModern[@]}"
    sudo apt-get install python3 -y -qq >> $LOG 2>&1
    curl -sfSL https://bootstrap.pypa.io/get-pip.py -o get-pip.py >> $LOG 2>&1
    python3 get-pip.py --user >> $LOG 2>&1
    python3 -m pip install --user ansible-core --no-warn-script-location >> $LOG 2>&1
    source $HOME/.profile
    # k8s | post-installation
    loadingStop
    ANSIPING=$(ansible localhost -m ping 2>/dev/null)
    if which ansible >/dev/null 2>&1 && [[ "$ANSIPING" == *SUCCESS* ]]; then
        rm -f get-pip.py
        echo -ne "\n${SUCCESSMSG} | ansible-$(ansible --version | head -n1 | cut -d"[" -f2 | cut -d"]" -f1) installed."
    else
        echo -ne "\n${ERRORMSG} | ansible installation failed. Check $LOG for details."
    fi
    echo -e "\n"
}

# --------------------------------------------  zshrc contents  -------------------------------------------
zshrcContent() {
tee ~/.zshrc >> /dev/null << EOF
# zsh customization
export ZSH="\$HOME/.oh-my-zsh"
ZSH_THEME="agnoster"
plugins=(git zsh-autosuggestions zsh-syntax-highlighting kubectl)
source \$ZSH/oh-my-zsh.sh
TERM=xterm-256color

# Global
export KUBECONFIG=~/path/to/kubeconfig
alias bat="batcat"
alias ll="ls -la"

# SAS Viya variables
export ORDER=<ORDER>
export CADENCE=<cadence>
export VERSION=<version>
export VIYA_NS=<viya-namespace>
export VIYA_HOME=\$HOME/sas-viya/\$VIYA_NS
export DEPLOY=\$VIYA_HOME/deploy
export deploy=\$DEPLOY
export RELEASE=$(cat \$deploy/current_release.txt)

# SAS Viya CLI
export SAS_CLI_PROFILE=<sas-viya-cli-profile-name>
export SSL_CERT_FILE="\$VIYA_HOME/viya-utilities/\$SAS_CLI_PROFILE.pem"
export REQUESTS_CA_BUNDLE="\$VIYA_HOME/viya-utilities/\${SAS_CLI_PROFILE}_CA.pem"

# Container Registry
#DOCKER_OPTS="--insecure-registry=registry.domain.com:port"
export REGISTRY="<cr.hostname.com>"
export REGISTRY_USER="<username>"
export REGISTRY_PASS="<password>"

# OpenShift
#export OCPSERVER="https://api.ocpdemo.domain.com:6443"
#export OCPUSER="ocpadmin"
#alias oc-login="oc login -u \$OCPUSER --server \$OCPSERVER --insecure-skip-tls-verify=true"

# Kubectl aliases
alias kgpv="kubectl get pv"
alias kgsc="kubectl get storageclass"
alias kdel="kubectl delete pod"
alias klog="kubectl logs -f"
alias kns="node-shell"
alias kdelj="kubectl get jobs --no-headers | grep '1/1' | awk '{print \$1}' | xargs -I {} kubectl delete job {}"

# SAS Viya aliases
alias setviya="kubectl config set-context --current --namespace=\$VIYA_NS"
alias sas-viya-build="cd \$deploy && kustomize build -o site.yaml"
alias sas-viya-dobuild="docker run --rm -v ~/sas-viya/\$VIYA_NS:/cwd/ sas-orchestration create sas-deployment-cr --deployment-data /cwd/license/SASViyaV4_certs.zip --license /cwd/license/license.jwt --user-content /cwd/deploy --cadence-name \$CADENCE --cadence-version \$VERSION --cadence-release \$RELEASE --image-registry \$REGISTRY > \$deploy/\$VIYA_NS-sasdeployment.yaml"
#OpenShift: alias sas-viya-dobuild="podman-sas-viya="podman run --rm -v ~/sas-viya/\$VIYA_NS:/cwd/ sas-orchestration create sas-deployment-cr --deployment-data /cwd/license/SASViyaV4_certs.zip --license /cwd/license/license.jwt --user-content /cwd/deploy --cadence-name \$CADENCE --cadence-version \$VERSION --cadence-release \$RELEASE --image-registry \$REGISTRY --repository-warehouse http://hostname.com/sas_repos > \$deploy/\$VIYA_NS-sasdeployment.yaml"
alias sas-viya-deploy="cd \$deploy && 'kubectl apply --selector="sas.com/admin=cluster-api" --server-side --force-conflicts -f site.yaml && echo -e "1/4 Done" && kubectl apply --selector="sas.com/admin=cluster-wide" -f site.yaml && echo -e "2/4 Done" && kubectl apply --selector="sas.com/admin=cluster-local" -f site.yaml --prune && echo -e "3/4 Done" && kubectl apply --selector="sas.com/admin=namespace" -f site.yaml --prune && echo -e "4/4 Done"'"
alias sas-viya-redeploy="sas-viya-build && sas-viya-deploy"
alias sas-viya-update="sas-viya-redeploy && echo -e "Update configuration..." kubectl apply --selector="sas.com/admin=namespace" -f \$deploy/site.yaml --prune --prune-whitelist=autoscaling/v2/HorizontalPodAutoscaler && echo -e "Update configuration done.""
alias sas-viya-start="kubectl create job sas-start-all-`date +%s` --from cronjobs/sas-start-all -n \$VIYA_NS"
alias sas-viya-stop="kubectl create job sas-stop-all-`date +%s` --from cronjobs/sas-stop-all -n \$VIYA_NS"
alias sas-viya-status="watch -n1 'kubectl get sasdeployments -n \$VIYA_NS && echo -e && kubectl get pods -n \$VIYA_NS'"
alias sas-viya-k9s="k9s --kubeconfig \$KUBECONFIG --namespace \$VIYA_NS"

# Startup commands
# oc-login
export WORKDIR $VIYA_HOME

EOF
}

# -------------------------------------------  requiredClients  -------------------------------------------
requiredClients() {
    # requiredClients | log
    echo -ne "\n$DATETIME | ${INFOMSG} | Required clients installation procedure started." >> $LOG
    # requiredClients: kubectl | log
    echo -ne "\n$DATETIME | ${INFOMSG} | Required clients - kubectl installation procedure started." >> $LOG
    # requiredClients: kubectl | input
    KCTLVERMINSUPPORTED="24" # <--- Minimum supported version
    KCTLVERMAXSUPPORTED="28" # <--- Maximum supported version
    echo -e "${BYELLOW}----------------------------${NONE}"
    echo -e "${BYELLOW}       INPUT REQUIRED       ${NONE}"
    echo -e "${BYELLOW}----------------------------${NONE}"
    KUBECTLCHECK=0
    while [[ "$KUBECTLCHECK" -eq 0 ]]; do
        echo -e "Input kubectl version to be installed based on your Kubernetes Cluster version (example 1.27.7):"
        echo -e "Supported versions: 1.${KCTLVERMINSUPPORTED}.0 - 1.${KCTLVERMAXSUPPORTED}.XX"
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
              echo -ne "\n${ERRORMSG} | kubectl version does not exist."
            else
              sudo install kubectl -o root -g root -m 755 /usr/local/bin >> $LOG 2>&1
              rm -f kubectl
            fi
            # requiredClients: kubectl | post-installation & check if installed
            loadingStop
            if which kubectl >/dev/null 2>&1; then
                KUBECTLCHECK=1
                echo -ne "\n${SUCCESSMSG} | kubectl $(kubectl version --client --short 2>/dev/null | awk 'NR==1{print $3}') installed."
            else
                echo -ne "\n${ERRORMSG} | kubectl installation failed. Check $LOG for details."
            fi
        else 
            echo -e "\n${ERRORMSG} | Kubectl version is incorrect, unsupported or null."
        fi
        echo -e "\n"
    done
    # requiredClients: kustomize | log
    echo -ne "\n$DATETIME | ${INFOMSG} | Required clients - kustomize installation procedure started." >> $LOG
    # requiredClients: kustomize | input
    KUSTOMIZESUPPORTED1="3.7.0" # for SAS Viya <= SAS Viya 2023.01
    KUSTOMIZESUPPORTED2="4.5.7" # for SAS Viya 2023.02 - performance issues!
    KUSTOMIZESUPPORTED3="5.0.0" # for SAS Viya >= 2023.03 and <= 2023.05
    KUSTOMIZESUPPORTED4="5.0.3" # for SAS Viya >= 2023.06 and <= 2023.11
    KUSTOMIZESUPPORTED5="5.1.1" # for SAS Viya 2023.12 or later
    echo -e "${BYELLOW}----------------------------${NONE}"
    echo -e "${BYELLOW}       INPUT REQUIRED       ${NONE}"
    echo -e "${BYELLOW}----------------------------${NONE}"
    KUSTOCHECK=0
    while [[ "$KUSTOCHECK" -eq 0 ]]; do
        echo -e "Supported kustomize versions:"
        echo -e "$KUSTOMIZESUPPORTED1 | SAS Viya <= 2022.09"
        echo -e "$KUSTOMIZESUPPORTED2 | SAS Viya 2023.02 - performance issues!"
        echo -e "$KUSTOMIZESUPPORTED3 | SAS Viya >= 2023.03 and <= 2023.05"
        echo -e "$KUSTOMIZESUPPORTED4 | SAS Viya >= 2023.06 and <= 2023.11"
        echo -e "$KUSTOMIZESUPPORTED5 | SAS Viya 2023.12 or later"
        echo ""
        echo -e "Input kustomize version to be installed based on your SAS Viya version:"
        read KUSTOMIZEVERSION
        if  [[ "$KUSTOMIZEVERSION" == "$KUSTOMIZESUPPORTED1" ]] || \
            [[ "$KUSTOMIZEVERSION" == "$KUSTOMIZESUPPORTED2" ]] || \
            [[ "$KUSTOMIZEVERSION" == "$KUSTOMIZESUPPORTED3" ]] || \
            [[ "$KUSTOMIZEVERSION" == "$KUSTOMIZESUPPORTED4" ]] || \
            [[ "$KUSTOMIZEVERSION" == "$KUSTOMIZESUPPORTED5" ]]; then
            # requiredClients: kustomize | pre-installation
            echo 
            echo -e "INFO: Installing kustomize $KUSTOMIZEVERSION..."
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
                echo -ne "\n${SUCCESSMSG} | kustomize $(kustomize version) installed."
            else
                echo -ne "\n${ERRORMSG} | kustomize installation failed. Check $LOG for details."
            fi
        else 
            echo -e "\n${ERRORMSG} | Kustomize version is incorrect, unsupported or null."
        fi
        echo -e "\n"
    done
    # requiredClients: node-shell | log
    echo -ne "\n$DATETIME | ${INFOMSG} | Required clients - node-shell installation procedure started." >> $LOG
    # requiredClients: node-shell | pre-installation
    echo -e "INFO: Installing latest node-shell..."
    cd $deploy
    loadingStart "${loadAniModern[@]}"
    # requiredClients: node-shell | installation
    curl -fsSL -o kubectl-node_shell https://raw.githubusercontent.com/kvaps/kubectl-node-shell/master/kubectl-node_shell >> $LOG 2>&1
    sudo install kubectl-node_shell -o root -g root -m 755 /usr/local/bin/node-shell >> $LOG 2>&1
    rm -f kubectl-node_shell
    # requiredClients: node-shell | post-installation & check if installed
    loadingStop
    if which node-shell >/dev/null 2>&1; then
        echo -ne "\n${SUCCESSMSG} | node-shell $(node-shell --version | awk 'NR==1{print $2}') installed."
    else
        echo -ne "\n${ERRORMSG} | node-shell installation failed. Check $LOG for details."
    fi
    echo -e "\n"
    # requiredClients: helm 3 | log
    echo -ne "\n$DATETIME | ${INFOMSG} | Required clients - helm 3 installation procedure started." >> $LOG
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
        echo -ne "\n${SUCCESSMSG} | Helm $(helm version --short | cut -d+ -f1) installed."
    else
        echo -ne "\n${ERRORMSG} | Helm installation failed. Check $LOG for details."
    fi
    echo -e "\n"
    # requiredClients: yq | log
    echo -ne "\n$DATETIME | ${INFOMSG} | Required clients - yq installation procedure started." >> $LOG
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
        echo -ne "\n${SUCCESSMSG} | yq $(yq --version | cut -d" " -f4) installed."
    else
        echo -ne "\n${ERRORMSG} | yq installation failed. Check $LOG for details."
    fi
    echo -e "\n"
    # requiredClients: k9s | log
    echo -ne "\n$DATETIME | ${INFOMSG} | Required clients - k9s installation procedure started." >> $LOG
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
        echo -ne "\n${SUCCESSMSG} | k9s $(k9s version | grep "Version:" | awk '{print $2}') installed."
    else
        echo -ne "\n${ERRORMSG} | k9s installation failed. Check $LOG for details."
    fi
    echo -e "\n"
}

# ---------------------------------------------  orderDownload  --------------------------------------------

viya4OrdersCli() {
    # viya4OrdersCli | log
    echo -ne "\n$DATETIME | ${INFOMSG} | viya4-orders-cli installation procedure started." >> $LOG
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
        echo -ne "\n${SUCCESSMSG} | viya4-orders-cli $(viya4-orders-cli --version | cut -d" " -f3) installed."
        echo -e "\n"
        clientCredentials
    else
        VIYA4ORDERSCLICHECK=0
        echo -ne "\n${ERRORMSG} | viya4-orders-cli installation failed. Check $LOG for details."
    fi
    echo -e "\n"
}

clientCredentials() {
    # clientCredentials | log
    echo -ne "\n$DATETIME | ${INFOMSG} | clientCredentials definition procedure started." >> $LOG
    # viya4OrdersCli | define clientCredentials
    if [[ "$VIYA4ORDERSCLICHECK" -eq 1 ]]; then
      echo -e "${BYELLOW}----------------------------${NONE}"
      echo -e "${BYELLOW}       INPUT REQUIRED       ${NONE}"
      echo -e "${BYELLOW}----------------------------${NONE}"
      echo -e "${BYELLOW}NOTE${NONE}: The script doesn't check whether your clientCredentials are correct or not."
      echo -e "Make sure you're copy/pasting your clientCredentials directly from https://apiportal.sas.com/my-apps."
      sleep 3
      VIYA4CREDSAVED=0
      while [[ "$VIYA4CREDSAVED" -eq 0 ]]; do
        echo -e "\nInput your clientCredentialsId ${BCYAN}(Key)${NONE}:"
        read CLCREDID
        CLCREDIDB64=$(echo -n $CLCREDID | base64)
        echo -e "\nInput your clientCredentialsSecret ${BCYAN}(Secret)${NONE}:"
        read CLCREDSEC
        CLCREDSECB64=$(echo -n $CLCREDSEC | base64) 
        echo -e "clientCredentialsId: $CLCREDIDB64\nclientCredentialsSecret: $CLCREDSECB64" > $HOME/.viya4-orders-cli
        unset CLCREDID CLCREDSEC CLCREDIDB64 CLCREDSECB64
        if [[ -s $HOME/.viya4-orders-cli ]]; then
          VIYA4CREDSAVED=1
          echo -e "\n${SUCCESSMSG} | Your clientCredentials were encoded and saved in $HOME/.viya4-orders-cli."
        fi
      done
    else
      echo -ne "\n${ERRORMSG} | viya4-orders-cli is not installed.\n"
      echo -e "${BYELLOW}----------------------------${NONE}"
      echo -e "${BYELLOW}       INPUT REQUIRED       ${NONE}"
      echo -e "${BYELLOW}----------------------------${NONE}"
      RETURNSELECTIONCC=0
      while [[ "$RETURNSELECTIONCC" -eq 0 ]]; do
          echo -e "Input ${BYELLOW}1${NONE} : to retry viya4-orders-cli installation."
          echo -e "Input ${BYELLOW}q${NONE} : to exit the tool."
          echo -e "\n"
          read RETURNSELECTCC
          if [[ "$RETURNSELECTCC" -eq 1 ]]; then
            RETURNSELECTIONCC=1
            viya4OrdersCli
          elif [[ "$RETURNSELECTCC" == "q" ]]; then
            RETURNSELECTIONCC=1
            exitTool
          else
            echo -e "\n${ERRORMSG} | Invalid input. Accepted inputs [1/q]."
          fi
      done
    fi
}

getOrder() {
    # getOrder | log
    echo -ne "\n$DATETIME | ${INFOMSG} | Order download procedure started." >> $LOG
    # getOrder | input order number
    echo -e "${BYELLOW}----------------------------${NONE}"
    echo -e "${BYELLOW}       INPUT REQUIRED       ${NONE}"
    echo -e "${BYELLOW}----------------------------${NONE}"
    ORDERCHECK=0
    while [[ "$ORDERCHECK" -eq 0 ]]; do
      echo -e "Input software Order Number (example 9CT4FQ):"
      read ORDER
      # getOrder | check if order number is valid (6 characters / second character is a capital letter / only numbers and caps / starts with 0 or 9C) - set ORDERCHECK1=true
      if [[ ${#ORDER} -eq 6 ]] && [[ $(echo $ORDER | cut -b2) =~ ^[A-Z]+$ ]] && [[ $(echo $ORDER) =~ ^[0-9A-Z]+$ ]] && [[ $(echo $ORDER) =~ ^(0|9C) ]]; then
          ORDERCHECK=1
      else
          echo -e "\n${ERRORMSG} | Invalid Order Number."
          echo -e "${BYELLOW}NOTE${NONE}: A valid Order Number:"
          echo -e "- Consists of 6 alphanumeric [0-9,A-Z] characters (no lowercase)"
          echo -e "- Starts with '0' (if internal) or '9C' (if external)"
          echo -e "- If the second character is capital letter 'C' for external orders or [A-Z] for internal ones"
      fi
    done
    ## getOrder | input cadence and version
    CADENCECHECK=0
    VERSIONCHECK=0  
    while [[ "$CADENCECHECK" -eq 0 ]] ; do
        echo -e "\nInput software Cadence [stable/lts]:"
        read CADENCE
        ## getOrder | check if cadence is valid
        if [[ "$CADENCE" == stable ]] || [[ "$CADENCE" == lts ]]; then
            CADENCECHECK=1
            ## getOrder | input version
            while [[ "$VERSIONCHECK" -eq 0 ]]; do
                echo -e "\nInput SAS Viya software version (example 2024.03):"
                read VERSION
                VERSIONY=$(echo $VERSION | cut -d"." -f1)
                VERSIONM=$(echo $VERSION | cut -d"." -f2)
                VERSIONMOCTAL=$(echo $VERSIONM | sed 's/^0*//') # remove leading zero
                ## getOrder | check if version is valid / supported
                if [[ "$CADENCE" == stable ]]; then
                    if  [[ "$VERSIONY" -eq 2023 && "$VERSIONMOCTAL" -eq 12 && ${#VERSION} -eq 7 ]] || \
                        [[ "$VERSIONY" -eq 2024 && "$VERSIONMOCTAL" -ge 1 && "$VERSIONMOCTAL" -le 3 && ${#VERSION} -eq 7 ]]; then
                        VERSIONCHECK=1
                    else
                        echo -e "\n${ERRORMSG} | Invalid or unsupported software Version for stable Cadence."
                        echo -e "Supported stable versions: Min $ESVIYASTABLE | Max $LSVIYASTABLE."
                    fi
                elif [[ "$CADENCE" == lts ]]; then
                    if [[ "$VERSIONY" -eq 2022 && "$VERSIONMOCTAL" -eq 9 && ${#VERSION} -eq 7 ]]; then
                        VERSIONCHECK=1
                    elif [[ "$VERSIONY" -eq 2023 && ( "$VERSIONMOCTAL" -eq 3 || "$VERSIONMOCTAL" -eq 10 ) && ${#VERSION} -eq 7 ]]; then
                        VERSIONCHECK=1
                    else
                        echo -e "\n${ERRORMSG} | Invalid or unsupported software Version for LTS Cadence."
                        echo -e "Supported versions: Min LTS $ESVIYALTS | Max LTS $LSVIYALTS."
                    fi
                fi
            done
        else
            echo -e "\n${ERRORMSG} | Invalid software Cadence. Accepted inputs [stable/lts]."
        fi
    done
    ## getOrder | ask for info confirmation
    CONFIRMCHECK=0
    while [[ "$CONFIRMCHECK" -eq 0 ]]; do
        echo
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
            if [[ ! -d "$HOME/$VIYA_NS/license" ]]; then
              mkdir "$HOME/$VIYA_NS/license" >> $LOG 2>&1
            fi
            loadingStart "${loadAniModern[@]}"
            # getOrder | download
            cd "$HOME/$VIYA_NS"
            RELEASE=$(viya4-orders-cli deploymentAssets $ORDER $CADENCE $VERSION --file-name assets 2>/dev/null | grep CadenceRelease | cut -d' ' -f2) >> $LOG 2>&1
            echo $RELEASE > "$HOME/$VIYA_NS/current_release.txt"
            tar xf assets.tgz -C $deploy >> $LOG 2>&1
            cd "$HOME/$VIYA_NS/license" >> $LOG 2>&1
            viya4-orders-cli license $ORDER $CADENCE $VERSION --file-name license >> $LOG 2>&1
            viya4-orders-cli certs $ORDER --file-name SASViyaV4_certs >> $LOG 2>&1
            cd $deploy
            # getOrder | post-download checks
            loadingStop
            if [[ -f "$HOME/$VIYA_NS/assets.tgz" && -d "$HOME/$VIYA_NS/license" && -f "$HOME/$VIYA_NS/license/license.jwt" && -f "$HOME/$VIYA_NS/license/SASViyaV4_certs.zip" ]]; then
                printFinalDate
                echo -e "\n${SUCCESSMSG} | DeploymentAssets downloaded in $HOME/$VIYA_NS"
                echo -e "\n${SUCCESSMSG} | License and certificates downloaded in $HOME/$VIYA_NS/license."
            else
                RETURNSELECTION=0
                echo -e "\n${ERRORMSG} | Issue while downloading deploymentAssets, license and certificates."
                echo -e "${BYELLOW}NOTE${NONE}: Possible causes:"
                echo -e "- Invalid previously defined clientCredentials."
                echo -e "- Defined version is not available yet."
                echo -e "- You don't have permission to access this order. Make sure you can see it in https://my.sas.com."
                echo -e "- Order does not exist."
                echo -e "\n"
                echo -e "${BYELLOW}----------------------------${NONE}"
                echo -e "${BYELLOW}       INPUT REQUIRED       ${NONE}"
                echo -e "${BYELLOW}----------------------------${NONE}"
                while [[ "$RETURNSELECTION" -eq 0 ]]; do
                    echo -e "Input ${BYELLOW}1${NONE} : to re-insert order information."
                    echo -e "Input ${BYELLOW}2${NONE} : to re-insert your clientCredentials."
                    echo -e "Input ${BYELLOW}q${NONE} : to exit the tool."
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
                      echo -e "\n${ERRORMSG} | Invalid input. Accepted inputs [ 1 | 2 | q ]."
                    fi
                done
            fi
        elif [[ "$CONFIRM" == n ]]; then
            CONFIRMCHECK=1
            getOrder
        else
            echo -e "\n${ERRORMSG} | Confirmation failed due to invalid input. Accepted inputs [y/n].\n"
        fi
    done
}

printFinalDate() {
    LICFILE=$(cat "$HOME/$VIYA_NS/license/license.jwt")
    if [[ -f "$HOME/$VIYA_NS/license/license.jwt" ]]; then
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
        echo -e "The license ultimately expires on: ${BYELLOW}$FINALDATE${NONE}"
    fi
}

mirrormgrCli() {
    while [[ "$MIRRORMGRCHECK" -ne 1 ]]; do
        # mirrormgrCli | log
        echo -ne "\n$DATETIME | ${INFOMSG} | SAS Mirror Manager installation procedure started." >> $LOG
        # mirrormgrCli | pre-installation
        echo -e "\nInstalling latest mirrormgr..."
        loadingStart "${loadAniModern[@]}"
        # mirrormgrCli | pre-installation
        mkdir "$deploy/mirrormgr" && cd "$deploy/mirrormgr" >> $LOG 2>&1
        wget -N https://support.sas.com/installation/viya/4/sas-mirror-manager/lax/mirrormgr-linux.tgz > /dev/null 2>&1
        tar --extract --file mirrormgr-linux.tgz mirrormgr >> $LOG 2>&1
        sudo install mirrormgr -o root -g root -m 755 /usr/local/mirrormgr >> $LOG 2>&1
        cd $deploy
        rm -rf "$deploy/mirrormgr"
        # mirrormgrCli | post-installation
        loadingStop
        if which mirrormgr >/dev/null 2>&1; then
            MIRRORMGRCHECK=1
            echo -ne "\n${SUCCESSMSG} | SAS Mirror Manager $(mirrormgr -v | awk '/version/ {match($0, /version[[:space:]]*:[[:space:]]*(v[[:digit:].-]+)/, arr); print arr[1]}') installed."
            echo -e "\n"
        else
            MIRRORMGRCHECK=0
            echo -ne "\n${ERRORMSG} | SAS Mirror Manager installation failed. Check $LOG for details."
        fi
        echo -e "\n"
    done
}

# ---------------------------------------------- terraform ----------------------------------------------

terraformClient() {
    # terraformClient | log
    echo -ne "\n$DATETIME | ${INFOMSG} | terraform installation procedure started." >> $LOG
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
        echo -e "\n${SUCCESSMSG} | terraform $(terraform version | awk 'NR==1{print $2}') installed."
    else
        TERRAFORMCLICHECK=0
        echo -e "\n${ERRORMSG} | terraform installation failed. Check $LOG for details."
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
            echo -e "\n${ERRORMSG} | terraform is not installed.\n"
            echo -e "${BYELLOW}----------------------------${NONE}"
            echo -e "${BYELLOW}       INPUT REQUIRED       ${NONE}"
            echo -e "${BYELLOW}----------------------------${NONE}"
            while [[ "$RETURNSELECTIONTF" -ne 1 ]]; do
                echo -e "Input ${BYELLOW}1${NONE} : to re-try terraform installation."
                echo -e "Input ${BYELLOW}q${NONE} : to exit the tool."
                echo -e "\n"
                read RETURNSELECTTF
                if [[ "$RETURNSELECTTF" -eq 1 ]]; then
                  RETURNSELECTIONTF=1
                  terraformClient
                elif [[ "$RETURNSELECT" == "q" ]]; then
                  RETURNSELECTIONTF=1
                  exitTool
                else
                  echo -e "\n${ERRORMSG} | Invalid input. Accepted inputs [1/q]."
                fi
            done
        fi
    fi
}

terraformAzureConfig() {
    # terraformAzureConfig | log
    echo -ne "\n$DATETIME | ${INFOMSG} | Azure/Terraform binding procedure started." >> $LOG
    # terraformAzureConfig | input
    while [[ -z "${AZSP}" ]]; do
      echo -e "${BYELLOW}----------------------------${NONE}"
      echo -e "${BYELLOW}       INPUT REQUIRED       ${NONE}"
      echo -e "${BYELLOW}----------------------------${NONE}"
      echo -e "Input desired ServicePrincipal name to be bound to Terraform:"
      read AZSP
        if [[ -z "${AZSP}" ]]; then
          echo -e "\n${ERRORMSG} | Azure ServicePrincipal not set or null."
        fi
    done
    echo -e "\nCurrent Service Principal: ►►► $AZSP ◄◄◄"
    echo -e "\nLaunching ${ITALIC}az login${NONE}:"
    az login --use-device-code -o table --query "[].{Name:name, IsDefault:isDefault, State:state, TenantId:tenantId}"
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
    TF_VAR_client_secret=$(az ad sp create-for-rbac --role "Contributor" --scopes="/subscriptions/$TF_VAR_subscription_id" --name http://$AZSP --query password --output tsv --only-show-errors 2> /dev/null)
    export TF_VAR_client_secret
    ## obtain the client ID
    TF_VAR_client_id=$(az ad sp list --display-name http://$AZSP --query "[0].appId" | sed -e 's/^"//' -e 's/"$//')
    export TF_VAR_client_id
    # write values to .terraform.env
    echo -e "TF_VAR_tenant_id=$TF_VAR_tenant_id\nTF_VAR_subscription_name=$TF_VAR_subscription_name\nTF_VAR_subscription_id=$TF_VAR_subscription_id\nTF_VAR_client_secret=$TF_VAR_client_secret\nTF_VAR_client_id=$TF_VAR_client_id" > $HOME/.terraform.env
    # show information
    echo -e "Azure/Terraform binding information:\n"
    echo -e "${BYELLOW}---------------------------------------------------------${NONE}"
    echo -e "Tenant ID:       $TF_VAR_tenant_id"
    echo -e "Subscription:    $TF_VAR_subscription_name"
    echo -e "Subscription ID: $TF_VAR_subscription_id"
    echo -e "ClientID:        $TF_VAR_client_id"
    echo -e "ClientSecret:    $TF_VAR_client_secret"
    echo -e "${BYELLOW}---------------------------------------------------------${NONE}"
    ## sourcing terraform vars in ~/.bashrc
    if [[ -s $HOME/.terraform.env ]]; then
      echo -e "\nsource ~/.terraform.env" >> $HOME/.bashrc && source $HOME/.bashrc
      echo -e "\n${SUCCESSMSG} | Variables saved in ~/.terraform.env. File sourced in ~/.bashrc"
    else
      TFENVCHECK=0
      echo -e "${BYELLOW}----------------------------${NONE}"
      echo -e "${BYELLOW}     ATTENTION REQUIRED     ${NONE}"
      echo -e "${BYELLOW}----------------------------${NONE}"
      echo -e "\n${ERRORMSG} | ~/.terraform.env could not be created.\n"
      echo -e "\nManually create the ~/.terraform.env file and add the following lines in it.\n"
      echo -e "TF_VAR_tenant_id=$TF_VAR_tenant_id"
      echo -e "TF_VAR_subscription_name=$TF_VAR_subscription_name"
      echo -e "TF_VAR_subscription_id=$TF_VAR_subscription_id"
      echo -e "TF_VAR_client_secret=$TF_VAR_client_secret"
      echo -e "TF_VAR_client_id=$TF_VAR_client_id"
      while [[ "$TFENVCHECK" -eq 0 ]];do
        echo -e "Input ${BYELLOW}1${NONE} : after manually adding the above into ~/.terraform.env."
        echo -e "Input ${BYELLOW}q${NONE} : to exit the tool."
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
          echo -e "\n${ERRORMSG} | Invalid input. Accepted inputs [1/q]."
        fi
      done
    fi
    echo -e "\nCloning viya4-iac-azure repository from https://github.com/sassoftware/viya4-iac-azure..."
    IACDESTINATION="$deploy/viya4-iac-azure"
    git clone https://github.com/sassoftware/viya4-iac-azure $IACDESTINATION >> $LOG 2>&1
    if [ -d "$IACDESTINATION" ] && [ "$(ls -A "$IACDESTINATION")" ]; then
      echo -e "\n${SUCCESSMSG} | Repository cloned in $deploy/viya4-iac-azure."
      echo -e "\nValidating Terraform..."
      loadingStart "${loadAniModern[@]}"
      cd $IACDESTINATION
      terraform init >> $LOG 2>&1
      if terraform validate -json | grep -q '"valid": true,' && ! terraform validate -json | grep -q '"valid": false,'; then
          loadingStop
          echo -e "\n${SUCCESSMSG} | Azure/Terraform binding succeeded."
      fi
      loadingStop
    else
      AZTFCHECK=0
      unset AZSP AZSUBSCRIPTION
      echo -e "\n${ERRORMSG} | Azure/Terraform binding failed.\n"
      echo -e "${BYELLOW}----------------------------${NONE}"
      echo -e "${BYELLOW}       INPUT REQUIRED       ${NONE}"
      echo -e "${BYELLOW}----------------------------${NONE}"
      while [[ "$AZTFCHECK" -eq 0 ]]; do
        echo -e "Input ${BYELLOW}1${NONE} : to re-try Azure/Terraform binding."
        echo -e "Input ${BYELLOW}q${NONE} : to exit the tool."
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
          echo -e "\n${ERRORMSG} | Invalid input. Accepted inputs [1/q]."
        fi
      done
    fi
}

terraformAWSConfig() {
    # terraformAWSConfig | log
    echo -ne "\n$DATETIME | ${INFOMSG} | AWS/Terraform binding procedure started." >> $LOG
    # terraformAWSConfig | input / credentials
    echo -e "${BYELLOW}----------------------------${NONE}"
    echo -e "${BYELLOW}       INPUT REQUIRED       ${NONE}"
    echo -e "${BYELLOW}----------------------------${NONE}"
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
          echo -e "\n${SUCCESSMSG} | aws-cli stored your Access key and secret in $HOME/.aws/credentials."
        else
          AWSCREDEX=0
          unset AZSP AZSUBSCRIPTION
          echo -e "\n${ERRORMSG} | AWS did not store your credentials in $HOME/.aws/credentials."
          echo -e "${BYELLOW}----------------------------${NONE}"
          echo -e "${BYELLOW}       INPUT REQUIRED       ${NONE}"
          echo -e "${BYELLOW}----------------------------${NONE}"
          while [[ "$AWSCREDEX" -eq 0 ]]; do
            echo -e "Input ${BYELLOW}1${NONE} : to re-try aws configure."
            echo -e "Input ${BYELLOW}q${NONE} : to exit the tool."
            echo -e "\n"
            read AWSRETRY
            if [[ "$AWSRETRY" -eq 1 ]]; then
              AWSCREDEX=0
            elif [[ "$AWSRETRY" == "q" ]]; then
              AWSCREDEX=0
              rm -f $HOME/.aws/credentials
              exitTool
            else
              echo -e "\n${ERRORMSG} | Invalid input. Accepted inputs [1/q]."
            fi
          done
        fi
      done
      echo -e "\nCloning viya4-iac-aws repository from https://github.com/sassoftware/viya4-iac-aws..."
      IACDESTINATION="$deploy/viya4-iac-aws"
      git clone https://github.com/sassoftware/viya4-iac-aws $IACDESTINATION >> $LOG 2>&1
      if [ -d "$IACDESTINATION" ] && [ "$(ls -A "$IACDESTINATION")" ]; then
        echo -e "\n${SUCCESSMSG} | Repository cloned in $deploy/viya4-iac-aws."
        echo -e "\nValidating Terraform..."
        loadingStart "${loadAniModern[@]}"
        cd $IACDESTINATION
        terraform init >> $LOG 2>&1
        if terraform validate -json | grep -q '"valid": true,' && ! terraform validate -json | grep -q '"valid": false,'; then
            loadingStop
            echo -e "\n${SUCCESSMSG} | AWS/Terraform binding succeeded."  
        else
          loadingStop
          AWSTFCHECK=0
          echo -e "\n${ERRORMSG} | AWS/Terraform binding failed.\n"
          echo -e "${BYELLOW}----------------------------${NONE}"
          echo -e "${BYELLOW}       INPUT REQUIRED       ${NONE}"
          echo -e "${BYELLOW}----------------------------${NONE}"
          while [[ "$AWSTFCHECK" -eq 0 ]]; do
            echo -e "Input ${BYELLOW}1${NONE} : to re-try AWS/Terraform binding."
            echo -e "Input ${BYELLOW}q${NONE} : to exit the tool."
            echo -e "\n"
            read AWSTFRETRY
            if [[ "$AWSTFRETRY" -eq 1 ]]; then
              AWSTFCHECK=1
              terraformAWSConfig
            elif [[ "$AWSTFRETRY" == "q" ]]; then
              AWSTFCHECK=1
              exitTool
            else
              echo -e "\n${ERRORMSG} | Invalid input. Accepted inputs [1/q]."
            fi
          done  
        fi
      fi
    fi   
}

terraformGCloudConfig() {
    # terraformGCloudConfig | log
    echo -ne "\n$DATETIME | ${INFOMSG} | GCP/Terraform binding procedure started." >> $LOG
    # terraformGCloudConfig | input / credentials
    echo -e "${BYELLOW}----------------------------${NONE}"
    echo -e "${BYELLOW}       INPUT REQUIRED       ${NONE}"
    echo -e "${BYELLOW}----------------------------${NONE}"
    echo -e "Create a new GCP Service Account or use an existing one?"
    GCPSACHOICE=0
    while [[ "$GCPSACHOICE" -eq 0 ]]; do
        echo -e "Input ${BYELLOW}1${NONE} : to create a new GCP Service Account (Recommended)."
        echo -e "Input ${BYELLOW}2${NONE} : to select an existing GCP Service Account."
        echo -e "Input ${BYELLOW}q${NONE} : to exit the tool."
        echo -e "\n"
        read GCPSASELECT
        if [[ "$GCPSASELECT" -eq 1 ]]; then
            while [[ -z "${GCPSA}" ]]; do
                echo -e "Input desired Service Account name for Terraform:"
                read GCPSA
                if [[ -z "${GCPSA}" ]]; then
                    echo -e "\n${ERRORMSG} | Service Account name not set or null."
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
                        echo -e "\n${ERRORMSG} | Service Account name not set or null."
                    else
                        GCPSACHOICE=1
                        GCPSAEXISTENT=1
                    fi
                else
                    echo -e "\nLaunching ${ITALIC}gcloud auth init${NONE}:"
                    echo -e "\n"
                    gcloud auth login --quiet
                    gcloud projects list --format="table(project_id)" | tail -n +2 | xargs -I {} sh -c 'echo -n "Project: {} | Email: "; gcloud iam service-accounts list --project {} --format="table(email)" | tail -n +2' | awk '{$1=$1};1'
                    echo -e "\nInput existing Service Account name for Terraform to use ${BYELLOW}(Only the name before '@' in Email)${NONE}:"
                    read GCPSA
                    if [[ -z "${GCPSA}" ]]; then
                        echo -e "\n${ERRORMSG} | Service Account name not set or null."
                    else
                        GCPSACHOICE=1
                    fi
                fi
            done
        elif [[ "$GCPSASELECT" -eq q ]]; then
            GCPSACHOICE=1
            exitTool
        else
            echo -e "\n${ERRORMSG} | Invalid input. Accepted inputs [ 1 | 2 | q ]."
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
    echo -e "${BYELLOW}-------------------------------------${NONE}"
    gcloud projects get-iam-policy $GCPPROJECTID --flatten="bindings[].members" --format='table(bindings.role)' --filter="bindings.members:$GCPSA" | grep -v ROLE | sort -u
    echo -e "${BYELLOW}-------------------------------------${NONE}"
    if [[ -s $GCPSA_KEY_FILE ]]; then
        echo -e "\n${SUCCESSMSG} | gcp-cli service account key file stored in $GCPSA_KEY_FILE."
    fi
    echo -e "\nCloning viya4-iac-gcp repository from https://github.com/sassoftware/viya4-iac-gcp..."
    IACDESTINATION="$deploy/viya4-iac-gcp"
    git clone https://github.com/sassoftware/viya4-iac-gcp $IACDESTINATION >> $LOG 2>&1
    if [ -d "$IACDESTINATION" ] && [ "$(ls -A "$IACDESTINATION")" ]; then
      echo -e "\n${SUCCESSMSG} | Repository cloned in $deploy/viya4-iac-gcp."
      echo -e "\nValidating Terraform..."
      loadingStart "${loadAniModern[@]}"
      cd $IACDESTINATION
      terraform init >> $LOG 2>&1
      if terraform validate -json | grep -q '"valid": true,' && ! terraform validate -json | grep -q '"valid": false,'; then
          loadingStop
          echo -e "\n${SUCCESSMSG} | GCP/Terraform binding succeeded."  
      else
        loadingStop
        GCPTFCHECK=0
        echo -e "\n${ERRORMSG} | GCP/Terraform binding failed.\n"
        echo -e "${BYELLOW}----------------------------${NONE}"
        echo -e "${BYELLOW}       INPUT REQUIRED       ${NONE}"
        echo -e "${BYELLOW}----------------------------${NONE}"
        while [[ "$GCPTFCHECK" -eq 0 ]]; do
          echo -e "Input ${BYELLOW}1${NONE} : to re-try GCP/Terraform binding."
          echo -e "Input ${BYELLOW}q${NONE} : to exit the tool."
          echo -e "\n"
          read GCPTFRETRY
          if [[ "$GCPTFRETRY" -eq 1 ]]; then
            GCPTFCHECK=1
            terraformGCloudConfig
          elif [[ "$GCPTFRETRY" == "q" ]]; then
            GCPTFCHECK=1
            exitTool
          else
            echo -e "\n${ERRORMSG} | Invalid input. Accepted inputs [1/q]."
          fi
        done  
      fi
    fi
}

terraformK8sConfig() {
    # terraformK8sConfig | clone repo
    echo -e "Cloning viya4-iac-k8s repository from https://github.com/sassoftware/viya4-iac-k8s..."
    IACDESTINATION="$deploy/viya4-iac-k8s"
    loadingStart "${loadAniModern[@]}"
    git clone https://github.com/sassoftware/viya4-iac-k8s $IACDESTINATION >> $LOG 2>&1
    if [ -d "$IACDESTINATION" ] && [ "$(ls -A "$IACDESTINATION")" ]; then
        loadingStop
        echo -e "\n${SUCCESSMSG} | Repository cloned in $deploy/viya4-iac-k8s."
        echo -e "\n${BYELLOW}INFO${NONE}: Navigate to ${ITALIC}${CYAN}https://github.com/sassoftware/viya4-iac-k8s#customize-input-values${NONE} and follow the steps from ${BYELLOW}Customize Input Values${NONE}"
    else
        IACK8S=0
        echo -e "\n${ERRORMSG} | Repository could not be cloned.\n"
        echo -e "${BYELLOW}----------------------------${NONE}"
        echo -e "${BYELLOW}       INPUT REQUIRED       ${NONE}"
        echo -e "${BYELLOW}----------------------------${NONE}"
        while [[ "$IACK8S" -eq 0 ]]; do
          echo -e "Input ${BYELLOW}1${NONE} : to re-try cloning."
          echo -e "Input ${BYELLOW}q${NONE} : to exit the tool."
          echo -e "\n"
          read IACK8SRETRY
          if [[ "$IACK8SRETRY" -eq 1 ]]; then
            IACK8S=1
            terraformK8sConfig
          elif [[ "$IACK8SRETRY" == "q" ]]; then
            IACK8S=1
            exitTool
          else
            echo -e "\n${ERRORMSG} | Invalid input. Accepted inputs [1/q]."
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
    mirrormgrCli
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
        echo -e "\n${ERRORMSG} | Cloud Provider not selected. A Cloud Provider must be selected."
        echo -e "${BYELLOW}----------------------------${NONE}"
        echo -e "${BYELLOW}       INPUT REQUIRED       ${NONE}"
        echo -e "${BYELLOW}----------------------------${NONE}"
        while [[ "$CPSELECT" -eq 0 ]]; do
        echo -e "Input ${BYELLOW}1${NONE} : to return to Cloud Provider Selection Menu."
        echo -e "Input ${BYELLOW}q${NONE} : to exit the tool."
        echo -e "\n"
        read CPSELECTION
        if [[ "$CPSELECTION" -eq 1 ]]; then
          CPSELECT=1
          providerMenu
        elif [[ "$CPSELECTION" == "q" ]]; then
          CPSELECT=1
          exitTool
        else
          echo -e "\n${ERRORMSG} | Invalid input. Accepted inputs [1/q]."
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
            echo -e "\n${ERRORMSG} | Invalid input. Accepted inputs [y/n]."
        fi
    done
    tfOnlyMode
    if [[ "$MODESELECTED" == "fullMode" ]]; then
        exitTool
    fi
}

# --------------------------------------------  startScript  --------------------------------------------

if [ "$#" -eq 0 ]; then
  providerMenu
elif [ "$1" == "--version" ]; then
    echo ""
    echo -e "${BCYAN}SAS Viya${NONE} ${BOLD}Initialization Tool${NONE}"
    echo "  $V4ITVER | $VERDATE"
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
    echo "   Supported SAS Viya versions:"
    echo "-----------------------------------"
    echo "- Stable $ESVIYASTABLE-$LSVIYASTABLE"
    echo "- LTS    $ESVIYALTS-$LSVIYALTS"
    echo "-----------------------------------"
    echo "NOTE: The tool is not maintained by SAS Institute Inc."
    echo "For support, open an issue at https://github.com/tonineri/viya4-init-tool"
    echo ""
    exit 0
elif [ "$1" == "--help" ]; then
    echo -e ""
    echo -e "-----------------------------------------------------------------------------------------------"
    echo -e "|                             ${BCYAN}SAS Viya${NONE} ${BOLD}Initialization Tool${NONE} - Usage                            |"
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
else
    echo -e "ERROR: Unsupported arguement."
    exit 0
fi

# ---------------------------------------------  scriptEnd  ---------------------------------------------
