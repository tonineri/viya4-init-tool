![SAS Viya](assets/sasviya_logo_header_gh.png)

<div align="center">

# **SAS Viya 4 Initialization Tool**

</div>

[![License](https://img.shields.io/badge/license-Apache%202.0-blue)](LICENSE.md)

## Overview
Welcome to the viya4-Init-Tool, a comprehensive and user-friendly solution designed to fully prepare a bastion host for SAS Viya 4 cluster creation and management on: 

* Microsoft Azure - [viya4-iac-azure](https://github.com/sassoftware/viya4-iac-azure) by [sassoftware](@sassoftware)
* Amazon Web Services - [viya4-iac-aws](https://github.com/sassoftware/viya4-iac-aws) by [sassoftware](@sassoftware)
* Google Cloud Plaform - [viya4-iac-gcp](https://github.com/sassoftware/viya4-iac-gcp) by [sassoftware](@sassoftware)
* Open Source Kubernetes - [viya4-iac-k8s](https://github.com/sassoftware/viya4-iac-k8s) by [sassoftware](@sassoftware)

This powerful tool streamlines the cluster initialization process by providing an interactive experience that guides you through each step, requesting input when necessary and ensuring a smooth setup experience.

## Key Features

* Comprehensive platform support: The Viya4-Init-Tool supports Azure, AWS, GCP, and Open Source K8s, providing a flexible solution for various cloud environments.
* Interactive user interface: The tool is designed to engage with you, prompting for necessary input and providing helpful feedback throughout the process.
* Two-tiered menu system: The tool features two distinct menus for selecting the Provider and Mode, allowing you to easily customize your experience based on your preferences and cloud environment.
* Guided process: Once you've made your selections, the tool will lead you through a comprehensive, step-by-step process tailored to your choices, ensuring you understand each step and have the opportunity to provide input where necessary.

## Requirements

>* Sudoer / Root
>* Internet access
>* Provider admin privileges

## Getting Started

To get started with the viya4-Init-Tool, follow these steps:

1. Clone the repository and navigate to the project directory:
```bash
cd ~
git clone https://github.com/tonineri/viya4-init-tool.git
cd viya4-init-tool
```

2. Run the main script to launch the tool:
```bash
chmod +x viya4-init-tool.sh
./viya4-init-tool.sh
```

3. Interact with the tool: Follow the on-screen prompts to navigate through the menus, select your `Provider` and `Mode`, and engage in the guided process tailored to your choices.

## Usage

The Viya4-Init-Tool consists of two menus:

1. **Provider Selection**: Choose from a list of supported cloud providers (Azure, AWS, GCP) or Open Source K8s. The provider selection determines the platform for which the tool will prepare the bastion host for SAS Viya 4 cluster creation and management.
<div align="center">

	![viya-init-tool | Provider Selection Menu](assets/providerSelectionMenu.png)

</div>

2. **Mode Selection**: Select the desired mode for your task. The modes determine the type of process you will be guided through and may vary depending on the chosen provider.

<div align="center">

	![viya-init-tool | Mode Selection Menu](assets/modeSelectionMenu.png)

</div>

After making your selections, you will be guided through a tailored process, with the tool asking for your input and providing feedback when necessary. This ensures a smooth, efficient, and user-centric experience.

## Contributing

We welcome contributions to improve the Viya4-Init-Tool. Please submit your ideas, bug reports, or feature requests via the [issue tracker](https://github.com/tonineri/viya4-init-tool/issues).

## License

> This project is licensed under the [Apache 2.0 License](LICENSE.md).

## Additional Resources

>* [Kubernetes](https://kubernetes.io/docs/tasks/tools/)
>* [Terraform](https://developer.hashicorp.com/terraform/intro)
>* [jq](https://stedolan.github.io/jq/)
>* [Docker](https://docs.docker.com/)
>* [Helm](https://helm.sh/docs/)
>* [Ansible](https://docs.ansible.com/ansible/2.9/index.html)
>* [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/)
>* [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-welcome.html)
>* [gCloud CLI](https://cloud.google.com/sdk/gcloud)
>* [viya4-iac-azure](https://github.com/sassoftware/viya4-iac-azure)
>* [viya4-iac-aws](https://github.com/sassoftware/viya4-iac-aws)
>* [viya4-iac-gcp](https://github.com/sassoftware/viya4-iac-gcp)
>* [viya4-iac-k8s](https://github.com/sassoftware/viya4-iac-k8s)
