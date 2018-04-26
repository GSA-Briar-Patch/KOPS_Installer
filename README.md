# KOPS Installer - Automated KOPS Installation

## Automatically Download, Extract and Install Latest or Specific Version

---

The **kops-install** script automates the process of downloading and installing Terraform.  It provides an ideal method for installing on new hosts, installing updates and downgrading if necessary.  This script detects the latest version, OS and CPU-Architecture and allows installation to local or system locations.  Optional parameters allow installing a specific version and installing to /usr/local/bin without prompting.


### Installation with this Installer

Download the installer and make executable

``` shell
wget https://raw.github.com/GSA-Briar-Patch/KOPS_Installer/master/KOPS_Install.sh && chmod +x KOPS_Install.sh
# or 
curl -LO https://raw.github.com/GSA-Briar-Patch/KOPS_Installer/master/KOPS_Install.sh && chmod +x KOPS_Install.sh

```

Run the installer

``` shell
./KOPS_Install.sh
```

### KOPS' Official Installation Process

- visit website download page
- locate version for OS/CPU and download
- find and extract binary from downloaded zip file
- copy binary to a directory on the PATH

### System Requirements

- System with Bash Shell (Linux, macOS, Windows Subsystem for Linux)
- `unzip` - terraform downloads are in zip format
