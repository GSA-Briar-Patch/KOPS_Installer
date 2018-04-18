#!/usr/bin/env bash

# KOPS INSTALLER - Automated KOPS Installation
#  Based on the work from Robert Peteuil  @RobertPeteuil
#   
#     Automatically Download, Extract and Install
#        Latest or Specific Version of KOPS
#


# Uncomment line below to always use 'sudo' to install to /usr/local/bin/
sudoInstall=true

scriptname=$(basename "$0")
scriptbuildnum="1.0.0"
scriptbuilddate="2018-04-17"

LATEST=$(wget -q -O- https://api.github.com/repos/kubernetes/kops/releases/latest 2> /dev/null | awk '/tag_name/ {print $2}' | cut -d '"' -f 2 | cut -d 'v' -f 2)

displayVer() {
  echo -e "${scriptname}  ver ${scriptbuildnum} - ${scriptbuilddate}"
}

usage() {
  [[ "$1" ]] && echo -e "Download and Install KOPS - Latest Version unless '-i' specified\n"
  echo -e "usage: ${scriptname} [-i VERSION] [-h] [-v]"
  echo -e "     -i VERSION\t: specify version to install in format '$LATEST' (OPTIONAL)"
  echo -e "     -a\t\t: automatically use sudo to install to /usr/local/bin"
  echo -e "     -h\t\t: help"
  echo -e "     -v\t\t: display ${scriptname} version"
}

if ! unzip -h 2&> /dev/null; then
  echo "Installing unzip"
  sudo apt-get install unzip
fi

while getopts ":i:ahv" arg; do
  case "${arg}" in
    a)  sudoInstall=true;;
    i)  VERSION=${OPTARG};;
    h)  usage x; exit;;
    v)  displayVer; exit;;
    \?) echo -e "Error - Invalid option: $OPTARG"; usage; exit;;
    :)  echo "Error - $OPTARG requires an argument"; usage; exit 1;;
  esac
done
shift $((OPTIND-1))

# POPULATE VARIABLES NEEDED TO CREATE DOWNLOAD URL AND FILENAME
if [[ -z "$VERSION" ]]; then
  VERSION=$LATEST
fi
OS=$(uname -s | tr '[:upper:]' '[:lower:]')
if [[ "$OS" == "linux" ]]; then
  PROC=$(lscpu 2> /dev/null | awk '/Architecture/ {if($2 == "x86_64") {print "amd64"; exit} else {print "386"; exit}}')
  if [[ -z $PROC ]]; then
    PROC=$(cat /proc/cpuinfo | awk '/flags/ {if($0 ~ /lm/) {print "arm64"; exit} else {print "386"; exit}}')
  fi
else
  PROC="amd64"
fi
[[ $PROC =~ arm ]] && PROC="arm"  # kops downloads use "arm" not full arm type

# CREATE FILENAME AND DOWNLOAD LINK BASED ON GATHERED PARAMETERS
FILENAME="kops_${OS}_${PROC}.zip"
LINK="https://github.com/kubernetes/kops/releases/download/${VERSION}/${FILENAME}"
LINKVALID=$(wget --spider -S "$LINK" 2>&1 | grep "HTTP/" | awk '{print $2}')

# VERIFY LINK VALIDITY
if [[ "$LINKVALID" != 200 ]]; then
  echo -e "Cannot Install - Download URL Invalid"
  echo -e "\nParameters:"
  echo -e "\tVER:\t$VERSION"
  echo -e "\tOS:\t$OS"
  echo -e "\tPROC:\t$PROC"
  echo -e "\tURL:\t$LINK"
  exit 1
fi

# DETERMINE DESTINATION
if [[ -w "/usr/local/bin" ]]; then
  BINDIR="/usr/local/bin"
  CMDPREFIX=""
  STREAMLINED=true
elif [[ "$sudoInstall" ]]; then
  BINDIR="/usr/local/bin"
  CMDPREFIX="sudo "
  STREAMLINED=true
else
  echo -e "KOPS Installer\n"
  echo "Specify install directory (a,b or c):"
  echo -en "\t(a) '~/bin'    (b) '/usr/local/bin' as root    (c) abort : "
  read -r -n 1 SELECTION
  echo
  if [ "${SELECTION}" == "a" ] || [ "${SELECTION}" == "A" ]; then
    BINDIR="${HOME}/bin"
    CMDPREFIX=""
  elif [ "${SELECTION}" == "b" ] || [ "${SELECTION}" == "B" ]; then
    BINDIR="/usr/local/bin"
    CMDPREFIX="sudo "
  else
    exit 0
  fi
fi

# CREATE TMPDIR FOR EXTRACTION
TMPDIR=${TMPDIR:-/tmp}
UTILTMPDIR="kops_${VERSION}"

cd "$TMPDIR" || exit 1
mkdir -p "$UTILTMPDIR"
cd "$UTILTMPDIR" || exit 1

# DOWNLOAD AND EXTRACT
wget -q "$LINK" -O "$FILENAME"
unzip -qq "$FILENAME" || exit 1

# COPY TO DESTINATION
mkdir -p "${BINDIR}" || exit 1
${CMDPREFIX} cp -f kops "$BINDIR" || exit 1

# CLEANUP AND EXIT
cd "${TMPDIR}" || exit 1
rm -rf "${UTILTMPDIR}"
[[ ! "$STREAMLINED" ]] && echo
echo "Terraform Version ${VERSION} installed to ${BINDIR}"

exit 0