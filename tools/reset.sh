#!/bin/bash
# uninstall previously installed packages (except for mlocate and git)
sudo apt remove google-cloud-sdk terraform unzip zip zsh -y 2>/dev/null
echo -e "removed gcloud-cli unzip zip mlocate git zsh"
# delete zsh configuration
sudo rm -rf $HOME/.zshrc* 2>/dev/null $HOME/.oh-my-zsh 2>/dev/null
echo -e "zsh customizations deleted"
# delete terraform configuration
sudo rm -rf $HOME/.terraform* 2>/dev/null 2>/dev/null
echo -e "terraform data deleted"
# delete deploydir 
sudo rm -rf $HOME/deploy 2>/dev/null
echo -e "deploydir deleted"
# delete viya4-orders-cli info
sudo rm -rf $HOME/.viya4-orders-cli 2>/dev/null
echo -e "viya4-orders-cli info deleted"
# delete azure cli saved info
sudo rm -rf $HOME/.azure 2>/dev/null
echo -e "az-cli configuration deleted"
# delete aws cli saved info
sudo rm -rf /usr/local/aws-cli $HOME/.aws 2>/dev/null
echo -e "aws-cli configuration deleted"
# delete gcloud cli saved indo
sudo apt-get purge google-cloud-sdk 2>/dev/null
sudo sed -i '/cloud-sdk/d' /etc/apt/sources.list.d/google-cloud-sdk.list 2>/dev/null
sudo rm -f /usr/share/keyrings/cloud.google.gpg 2>/dev/null
rm -rf /usr/lib/google-cloud-sdk $HOME/.config/gcloud 2>/dev/null
# clear /usr/local/bin
sudo rm -f /usr/local/bin/* 2>/dev/null 2>/dev/null
echo -e "/usr/local/bin/ cleared"
clear
