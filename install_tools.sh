#!/bin/bash

RED="\e[31m"
GREEN="\e[32m"
MAGENTA="\e[35m"
BLUE="\e[36m"
NC="\e[0m"

echo -e "${BLUE}[i]${NC} Updating apt..."
sudo apt update

# Install tools
tools_list=(
	assetfinder
	docker.io
	grepcidr
	gowitness
	httprobe
	jq
	peass
	sublist3r
	subfinder
)

for tool in "${tools_list[@]}"; do
	if ! command -v "$tool" &>/dev/null; then
		echo -e "${BLUE}[i]${NC} $tool is not installed."
		echo -e "${MAGENTA}[*]${NC} Installing $tool ..."
		sudo apt install "$tool" -y
		if [[ $? -eq 0 ]]; then
			echo -e "${GREEN}[+]${NC} $tool was installed."
		else
			echo -e "${RED}[!]${NC} There was an error by the installation of $tool."
		fi
	else
		echo -e "${BLUE}[i]${NC} $tool is already installed"
	fi
done

# Create necessary folders
./create_folders.sh

# Copy scripts/binaries in created folder
echo -e "${MAGENTA}[*]${NC} Copying scripts/binaries..."
cp /usr/share/peass/linpeas/linpeas.sh "$HOME/Pentesting/scripts/linux/bash/"
cp /usr/share/peass/winpeas/winPEAS.bat "$HOME/Pentesting/scripts/windows/"
cp /usr/share/peass/winpeas/winPEASx64.exe "$HOME/Pentesting/scripts/windows/"
cp /usr/share/peass/winpeas/winPEASx86.exe "$HOME/Pentesting/scripts/windows/"

echo -e "${MAGENTA}[*]${NC} Copying binaries..."

scripts_list=(
	githubdorker
	googledorker
	update-hosts
	vhost-fuzzer
)

for tool in "${scripts_list[@]}"; do
	sudo chmod +x "$tool" && cp "$tool" /usr/bin
done

# Download other tools on github
install_rustscan() {
	# Download latest rustscan
	LATEST_RUSTSCAN_RELEASE_URL=$(curl -s "https://api.github.com/repos/RustScan/RustScan/releases/latest" | grep "browser_download_url" | grep "amd64.deb" | cut -d '"' -f 4)
	FILE_NAME=$(basename "$LATEST_RUSTSCAN_RELEASE_URL")

	if [[ -z "$LATEST_RUSTSCAN_RELEASE_URL" ]]; then
		echo -e "${RED}[!]${NC} RUSTSCAN download link was not found!"
		exit 1
	fi
 
	echo -e "${BLUE}[*]${NC} Downloading rustscan..."
	if command -v wget &> /dev/null; then
		wget -q --show-progress "$LATEST_RUSTSCAN_RELEASE_URL"
	elif command -v curl &> /dev/null; then
		curl -L --progress-bar -O "$LATEST_RUSTSCAN_RELEASE_URL"
	else
		echo -e "${RED}[!]${NC} Could not download rustscan."
		exit 1
	fi
 
	echo -e "${BLUE}[*]${NC} Installing rustscan..."
	sudo dpkg -i "$FILE_NAME"
	sudo rm "$FILE_NAME"
  
  	if command -v rustscan &>/dev/null; then
   		echo -e "${GREEN}[+]${NC} rustscan is installed!"
   	else
    		echo -e "${RED}[!]${NC} rustscan could not be installed!"
  	fi
}

install_dalfox() {
	# Download latest dalfox
	LATEST_DALFOX_RELEASE_URL=$(curl -s "https://api.github.com/repos/hahwul/dalfox/releases/latest" | grep "browser_download_url" | grep "linux_amd64.tar.gz" | cut -d '"' -f 4)
	FILE_NAME=$(basename "$LATEST_DALFOX_RELEASE_URL")

	if [[ -z "$LATEST_DALFOX_RELEASE_URL" ]]; then
		echo -e "${RED}[!]${NC} Download-Link was not found!"
		exit 1
	fi
	echo -e "${MAGENTA}[*]${NC} Downloading dalfox..."
	if command -v wget &> /dev/null; then
		wget -q --show-progress "$LATEST_DALFOX_RELEASE_URL"
	elif command -v curl &> /dev/null; then
		curl -L --progress-bar -O "$LATEST_DALFOX_RELEASE_URL"
	else
		echo -e "${RED}[!]${NC} Could not download dalfox."
		exit 1
	fi

	echo -e "${MAGENTA}[*]${NC} Installing dalfox..."
	tar -xzf "$FILE_NAME"
	sudo chmod +x dalfox && cp dalfox /usr/bin
	rm "$FILE_NAME" dalfox LICENSE.txt README.md
 
 	if command -v dalfox &>/dev/null; then
   		echo -e "${GREEN}[+]${NC} dalfox is installed!"
   	else
    		echo -e "${RED}[!]${NC} dalfox could not be installed!"
  	fi
}

install_waybackurls() {
	# Download latest waybackurls
	LATEST_WAYBACKURLS_RELEASE_URL=$(curl -s "https://api.github.com/repos/tomnomnom/waybackurls/releases/latest" | grep "browser_download_url" | grep "linux-amd64" | grep ".tgz" | cut -d '"' -f 4)
	FILE_NAME=$(basename "$LATEST_WAYBACKURLS_RELEASE_URL")

	if [[ -z "$LATEST_WAYBACKURLS_RELEASE_URL" ]]; then
		echo -e "${RED}[!]${NC} Download-Link was not found!"
		exit 1
	fi
	echo -e "${MAGENTA}[*]${NC} Downloading waybackurls..."
	if command -v wget &> /dev/null; then
		wget -q --show-progress "$LATEST_WAYBACKURLS_RELEASE_URL"
	elif command -v curl &> /dev/null; then
		curl -L --progress-bar -O "$LATEST_WAYBACKURLS_RELEASE_URL"
	else
		echo -e "${RED}[!]${NC} Could not download waybackurls."
		exit 1
	fi

	echo -e "${MAGENTA}[*]${NC} Installing waybackurls..."
	tar -xzf "$FILE_NAME"
	sudo chmod +x waybackurls && cp waybackurls /usr/bin
	rm "$FILE_NAME" waybackurls

 	if command -v waybackurls &>/dev/null; then
   		echo -e "${GREEN}[+]${NC} waybackurls is installed!"
   	else
    		echo -e "${RED}[!]${NC} waybackurls could not be installed!"
  	fi
}

install_rustscan
install_dalfox
install_waybackurls
