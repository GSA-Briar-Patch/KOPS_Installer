# KOPS Installer - Automated KOPS Installation

## Automatically Download, Extract and Install Latest or Specific Version

---

The **kops-install** script automates the process of downloading and installing Terraform.  It provides an ideal method for installing on new hosts, installing updates and downgrading if necessary.  This script detects the latest version, OS and CPU-Architecture and allows installation to local or system locations.  Optional parameters allow installing a specific version and installing to /usr/local/bin without prompting.

Options:

- `-i VERSION`:  Install specific version
- `-a`:          Automatically use `sudo` to install to /usr/local/bin
  - allows for unattended installation via scripts or CD tools
  - can be set as default behavior by uncommenting line 12 (`sudoInstall=true`)
  - sudo password may be required unless NOPASSWD is enabled
- `-h`:          help
- `-v`:          display version

### Installation with this Installer

Download the installer and make executable

``` shell
wget https://raw.github.com/GSA-Briar-Patch/KOPS_Installer/master/terraform-install.sh
# or curl -LO https://raw.github.com/GSA-Briar-Patch/KOPS_Installer/master/terraform-install.sh
chmod +x terraform-install.sh
```

Run the installer

``` shell
./terraform-install.sh
```

Optional Parameters

``` shell
# -i = Install specific version
./KOPS_Install.sh -i 0.11.1

# -a = Automatic sudo install to /usr/local/bin/  (no user prompt)
./KOPS_install.sh -a
```

### KOPS' Official Installation Process

- visit website download page
- locate version for OS/CPU and download
- find and extract binary from downloaded zip file
- copy binary to a directory on the PATH

### System Requirements

- System with Bash Shell (Linux, macOS, Windows Subsystem for Linux)
- `unzip` - terraform downloads are in zip format

### Script Process Details

- Determines Version to Download and Install
  - Uses Version specified by `-i VERSION` parameter (if specified)
  - Otherwise determines Latest Version
    - Uses GitHub API to retrieve latest version number
- Calculates Download URL based on Version, OS and CPU-Architecture
- Verifies URL Validity before Downloading in Case:
  - VERSION incorrectly specified with `-i`
  - Download URL Format Changed on terraform Website
- Determines Install Destination
  - Performed before Download/Install Process in case user selects `abort`
- Installation Process
  - Download, Extract, Install, Cleanup and Display Results

#### CPU Architecture Detection

CPU architecture is detected for each OS accordingly:

- Linux / Windows (WSL since this is a Bash script)
  - detected with `lscpu` or by inspecting `/proc/cpuinfo`
- macOS - uses Default Arch `amd64` as it's the only version available on macOS
- Default Value - `amd64`

### Inspired by 

Apache 2.0 License - Copyright (c) 2018    Robert Peteuil