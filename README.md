<div align="center">

![SAS Viya](/assets/sasviya.png)

# **Initialization Tool**

[![License](https://img.shields.io/badge/license-Apache%202.0-blue)](LICENSE.md)

</div>

![divider](/assets/divider.png)

## Supported SAS Viya versions

| **Cadence** | **Version(s)** |
|---------|----------|
| **Stable**  | `2024.02` \| `2024.03` \| `2024.04` \| `2024.05` |
| **LTS**    | `2022.09` \| `2023.03` \| `2023.10` \| `2024.03` |

![divider](/assets/divider.png)

## Overview

Welcome to the `viya4-init-tool`, a comprehensive and user-friendly solution designed to fully prepare a bastion host for SAS Viya 4 cluster creation and management on:

* Microsoft Azure | [viya4-iac-azure](https://github.com/sassoftware/viya4-iac-azure) by [SAS](@sassoftware)
* Amazon Web Services | [viya4-iac-aws](https://github.com/sassoftware/viya4-iac-aws) by [SAS](@sassoftware)
* Google Cloud Plaform | [viya4-iac-gcp](https://github.com/sassoftware/viya4-iac-gcp) by [SAS](@sassoftware)
* Open Source K8s | [viya4-iac-k8s](https://github.com/sassoftware/viya4-iac-k8s) by [SAS](@sassoftware)

This powerful tool streamlines the cluster initialization process by providing an interactive experience that guides you through each step, requesting input when necessary and ensuring a smooth setup experience.

![divider](/assets/divider.png)

## Key Features

* **Comprehensive platform support**: The `viya4-init-tool` supports Azure, AWS, GCP, and Open Source K8s, providing a flexible solution for various cloud environments.
* **Interactive user interface**: The tool is designed to engage with you, prompting for necessary input and providing helpful feedback throughout the process.
* **Two-tiered menu system**: The tool features two distinct menus for selecting the Provider and Mode, allowing you to easily customize your experience based on your preferences and cloud environment.
* **Guided process**: Once you've made your selections, the tool will lead you through a comprehensive, step-by-step process tailored to your choices, ensuring you understand each step and have the opportunity to provide input where necessary.

![divider](/assets/divider.png)

## Prerequisites

Before using the `viya4-init-tool`, ensure you have met the following requirements:

* **Root or sudoer access**
  > The tool requires elevated privileges to perform certain tasks during the setup process.
* **Internet access**
  > A stable internet connection is necessary for downloading dependencies and interacting with cloud provider APIs.
* **Provider admin privileges**
  > Ensure you have administrator-level access to your chosen cloud provider, as the tool needs to perform tasks that require higher-level permissions.

![divider](/assets/divider.png)

## Getting Started

To get started with the `viya4-init-tool`, follow these steps:

1. Get the latest version of the tool:

 * Option 1 - Download the latest tarball:

  ```bash
  cd ~
  wget -O - https://github.com/tonineri/viya4-init-tool/releases/latest/download/viya4-init-tool.tgz | tar xz
  cd viya4-init-tool
  ```

 * Option 2 - Clone the repository:

  ```bash
  cd ~
  git clone https://github.com/tonineri/viya4-init-tool
  cd viya4-init-tool
  ```

2. Run the main script to launch the tool:

 ```bash
 chmod +x viya4-init-tool.sh
 ./viya4-init-tool.sh
 ```

3. Interact with the tool: Follow the on-screen prompts to navigate through the menus, select your `Provider` and `Mode`, and engage in the guided process tailored to your choices.

![divider](/assets/divider.png)

## Usage

* To run the tool, execute:

 ```bash
 ./viya4-init-tool.sh
 ```

You will be prompted to input the desired name for your SAS Viya namespace. The tool will then proceed with the two menus:

1. **Provider Selection Menu**: Choose from a list of supported cloud providers (Azure, AWS, GCP) or Open Source K8s. The provider selection determines the platform for which the tool will prepare the bastion host for SAS Viya 4  cluster creation and management.

  <div align="center"> 
  
  ![Provider Selection Menu](/assets/providerSelectionMenu.png)
  
  </div>

2. **Mode Selection Menu**: Select the desired mode for your task. The modes determine the type of process you will be guided through and may vary depending on the chosen provider.

  <div align="center"> 
  
  ![Mode Selection Menu](/assets/modeSelectionMenu.png) 
  
  </div>

After making your selections, you will be guided through a tailored process, with the tool asking for your input and providing feedback when necessary. This ensures a smooth, efficient, and user-centric experience.

* To show the tool version, execute:

 ```bash
 ./viya4-init-tool.sh --version
 ```

* To show the URLs that need to be whitelisted for the script to run fully, execute:

 ```bash
 ./viya4-init-tool.sh --whitelist
 ```

* To show the latest SAS Viya versions supported by the tool, execute:

 ```bash
 ./viya4-init-tool.sh --support
 ```

* To show the all available usage options, execute:

 ```bash
 ./viya4-init-tool.sh --help
 ```
![divider](/assets/divider.png)

## Contributing

We welcome contributions to improve the `viya4-init-tool`. Please submit your ideas, bug reports, or feature requests via the [issue tracker](https://github.com/tonineri/viya4-init-tool/issues).

![divider](/assets/divider.png)

## License

This project is licensed under the [Apache 2.0 License](LICENSE.md). 

![divider](/assets/divider.png)

## Additional Resources

>* [Kubernetes](https://kubernetes.io/docs/tasks/tools/)
>* [Terraform](https://developer.hashicorp.com/terraform/intro)
>* [jq](https://stedolan.github.io/jq/)
>* [k9s](https://github.com/derailed/k9s)
>* [zsh](https://github.com/ohmyzsh/ohmyzsh)
>* [Docker](https://docs.docker.com/)
>* [Helm](https://helm.sh/docs/)
>* [Ansible](https://docs.ansible.com/ansible/2.9/index.html)
>* [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/)
>* [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-welcome.html)
>* [gCloud CLI](https://cloud.google.com/sdk/gcloud)
>* [SAS Viya4-IaC-Azure](https://github.com/sassoftware/viya4-iac-azure)
>* [SAS Viya4-IaC-AWS](https://github.com/sassoftware/viya4-iac-aws)
>* [SAS Viya4-IaC-GCP](https://github.com/sassoftware/viya4-iac-gcp)
>* [SAS Viya4-IaC-k8s](https://github.com/sassoftware/viya4-iac-k8s)

![divider](/assets/divider.png)