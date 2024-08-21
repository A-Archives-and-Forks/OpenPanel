#!/bin/bash

# Update from OpenPanel 0.2.4 to 0.2.5

# new version
NEW_PANEL_VERSION="0.2.5"


# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
RESET='\033[0m'

# Directories
OPENADMIN_DIR="/usr/local/admin/"
OPENCLI_DIR="/usr/local/admin/scripts/"
OPENPANEL_LOG_DIR="/var/log/openpanel/"
SERVICES_DIR="/etc/systemd/system/"
TEMP_DIR="/tmp/"

OPENPANEL_DIR="/usr/local/panel/"
CURRENT_PANEL_VERSION=$(< ${OPENPANEL_DIR}/version)


LOG_FILE="${OPENPANEL_LOG_DIR}admin/notifications.log"
DEBUG_MODE=0


# block updates for older versions!
required_version="0.2.1"

if [[ "$CURRENT_PANEL_VERSION" < "$required_version" ]]; then
    # Version is less than 0.2.1, no update will be performed
    echo ""
    echo "NO UPDATES FOR VERSIONS =< 0.1.9 - PLEASE REINSTALL OPENPANEL"
    echo "Annoucement: https://community.openpanel.com/d/65-important-update-openpanel-version-021-announcement"
    echo ""
    exit 0
else
    # Version is 0.2.1 or newer
    echo "Starting update.."
fi




# Check if the --debug flag is provided
for arg in "$@"
do
    if [ "$arg" == "--debug" ]; then
        DEBUG_MODE=1
        break
    fi
done


    start_certbot(){
    cd /root && docker compose up -d certbot
    }
# HELPERS


# Display error and exit
radovan() {
    echo -e "${RED}Error: $2${RESET}" >&2
    exit $1
}


# Progress bar script
PROGRESS_BAR_URL="https://raw.githubusercontent.com/pollev/bash_progress_bar/master/progress_bar.sh"
PROGRESS_BAR_FILE="progress_bar.sh"
wget "$PROGRESS_BAR_URL" -O "$PROGRESS_BAR_FILE" > /dev/null 2>&1

if [ ! -f "$PROGRESS_BAR_FILE" ]; then
    echo "Failed to download progress_bar.sh"
    exit 1
fi

# Source the progress bar script
source "$PROGRESS_BAR_FILE"

# Dsiplay progress bar
FUNCTIONS=(

    #notify user we started
    print_header

    # fix for bug with php not autostarting
    php_fix
    
    # update images!
    update_docker_images

    #config
    update_config_files

    # update docker openpanel iamge
    download_new_panel

    # update admin from github
    download_new_admin

    # update opencli
    opencli_update

    # repalce ip with username in nginx container files
    nginx_change_in

    # start bind
    bind_also

    #remove nginx and certbot
    remove_nginx_certbot

    # setup mail server
    set_mailserver


    # ping us
    verify_license

    # new crons added
    set_system_cronjob

    # logrotate added in 025
    set_logrotate

    # file watcher removed in 025
    uninstall_watcher_service
    
    # openpanel/openpanel should be downloaded now!
    docker_compose_up_with_newer_images

    # certbot start
    start_certbot

    # if user created a post-update script, run it now
    run_custom_postupdate_script

    # yay! we made it
    celebrate

    # show to user what was done and how to restore previous version if needed!
    post_install_message

)

TOTAL_STEPS=${#FUNCTIONS[@]}
CURRENT_STEP=0

update_progress() {
    CURRENT_STEP=$((CURRENT_STEP + 1))
    PERCENTAGE=$(($CURRENT_STEP * 100 / $TOTAL_STEPS))
    draw_progress_bar $PERCENTAGE
}

main() {
    # Make sure that the progress bar is cleaned up when user presses ctrl+c
    enable_trapping
    
    # Create progress bar
    setup_scroll_area
    for func in "${FUNCTIONS[@]}"
    do
        # Execute each function
        $func
        update_progress
    done
    destroy_scroll_area
}



# print fullwidth line
print_space_and_line() {
    printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' -
}



# END helper functions









# START MAIN FUNCTIONS



# Function to write notification to log file
write_notification() {
  local title="$1"
  local message="$2"
  local current_message="$(date '+%Y-%m-%d %H:%M:%S') UNREAD $title MESSAGE: $message"

  echo "$current_message" >> "$LOG_FILE"
}



# logo
print_header() {
    printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' -
    echo -e "   ____                         _____                      _  "
    echo -e "  / __ \                       |  __ \                    | | "
    echo -e " | |  | | _ __    ___  _ __    | |__) | __ _  _ __    ___ | | "
    echo -e " | |  | || '_ \  / _ \| '_ \   |  ___/ / _\" || '_ \ / _  \| | "
    echo -e " | |__| || |_) ||  __/| | | |  | |    | (_| || | | ||  __/| | "
    echo -e "  \____/ | .__/  \___||_| |_|  |_|     \__,_||_| |_| \___||_| "
    echo -e "         | |                                                  "
    echo -e "         |_|                                                  "

    printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' -

    echo -e "Starting update to OpenPanel version $NEW_PANEL_VERSION"
    echo -e ""
    echo -e "Changelog: https://openpanel.com/docs/changelog/$NEW_PANEL_VERSION"        
    printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' -
    echo -e ""
}


update_docker_images() {
    #opencli docker-update_images
    #bash /usr/local/admin/scripts/docker/update_images
    echo "Downloading latest Nginx and Apache images from https://hub.docker.com/u/openpanel"
    echo ""
    nohup sh -c "echo openpanel/nginx:latest openpanel/apache:latest | xargs -P4 -n1 docker pull" </dev/null >nohup.out 2>nohup.err &
}


opencli_update(){
    echo "Updating OpenCLI commands from https://storage.googleapis.com/openpanel/${NEW_PANEL_VERSION}/get.openpanel.co/downloads/${NEW_PANEL_VERSION}/opencli/opencli-main.tar.gz"
    echo ""
    mkdir -p ${TEMP_DIR}opencli
    wget -O ${TEMP_DIR}opencli.tar.gz "https://storage.googleapis.com/openpanel/${NEW_PANEL_VERSION}/get.openpanel.co/downloads/${NEW_PANEL_VERSION}/opencli/opencli-main.tar.gz"
    cd ${TEMP_DIR} && tar -xzf opencli.tar.gz -C ${TEMP_DIR}opencli
    rm -rf /usr/local/admin/scripts/
    
    cp -r ${TEMP_DIR}opencli/ /usr/local/admin/scripts/
    rm ${TEMP_DIR}opencli.tar.gz 
    rm -rf ${TEMP_DIR}opencli

    cp /usr/local/admin/scripts/opencli /usr/local/bin/opencli
    chmod +x /usr/local/bin/opencli
    chmod +x -R /usr/local/admin/scripts/
    opencli commands
    echo "# opencli aliases
    ALIASES_FILE=\"/usr/local/admin/scripts/aliases.txt\"
    generate_autocomplete() {
        awk '{print \$NF}' \"\$ALIASES_FILE\"
    }
    complete -W \"\$(generate_autocomplete)\" opencli" >> ~/.bashrc
    
    source ~/.bashrc
}




remove_nginx_certbot(){


systemctl stop nginx.service
systemctl disable nginx.service
service nginx stop
service nginx disable
apt-get remove nginx nginx-common -y

systemctl stop bind9
apt-get remove bind9 -y

systemctl stop certbot.service
systemctl disable certbot.service
service certbot stop
service certbot disable
apt-get remove certbot -y


apt autoremove -y

systemctl daemon-reload

}


bind_also(){

    echo " DNSStubListener=no" >>  /etc/systemd/resolved.conf  && systemctl restart systemd-resolved
    service docker restart #Error response from daemon: Get "https://registry-1.docker.io/v2/": dial tcp: lookup registry-1.docker.io on 127.0.0.53:53: read udp 127.0.0.1:51883->127.0.0.53:53: read: connection refused
    cd /root && docker compose up -d bind9

}


nginx_change_in(){


    mkdir -p /etc/letsencrypt/
    rm /etc/openpanel/nginx/options-ssl-nginx.conf
    ln -s /etc/openpanel/nginx/options-ssl-nginx.conf /etc/letsencrypt/options-ssl-nginx.conf
    openssl dhparam -out /etc/letsencrypt/ssl-dhparams.pem 2048

    rm /etc/nginx/sites-enabled/default
    rm /etc/nginx/sites-available/default


    # Check if jq is installed
    if ! command -v jq &> /dev/null; then
        # Install jq using apt
        sudo apt-get update > /dev/null 2>&1
        sudo apt-get install -y -qq jq > /dev/null 2>&1
        # Check if installation was successful
        if ! command -v jq &> /dev/null; then
            echo "Error: jq installation failed. Please install jq manually and try again."
            exit 1
        fi
    fi
    
DOCKER_USERS=$(opencli user-list --json | jq -r '.[].username')

# Loop kroz Docker usere i pokreni skript
for USERNAME in $DOCKER_USERS; do
    # Run the user-specific script
    opencli nginx-update_vhosts $USERNAME
done


opencli server-recreate_hosts
docker exec nginx  nginx -s reload
cd /root && docker compose up -d nginx

}


run_custom_postupdate_script() {

    echo "Checking if post-update script is provided.."
    echo ""
    # Check if the file /root/openpanel_run_after_update exists
    if [ -f "/root/openpanel_run_after_update" ]; then
        echo " "
        echo "Running post update script: '/root/openpanel_run_after_update'"
        echo "https://dev.openpanel.com/customize.html#After-update"
        bash /root/openpanel_run_after_update

    fi
}



set_mailserver(){
    opencli email-server install
}

set_logrotate(){
config_file="/etc/openpanel/openpanel/conf/openpanel.config"

if [ ! -f "$config_file" ]; then
    echo "Configuration file does not exist: $config_file"
    exit 1
fi

# Check if 'logrotate_enable' is present in the config file
if ! grep -q "logrotate_enable=" "$config_file"; then
    cat <<EOL >> "$config_file"

[LOGS]
logrotate_enable=yes
logrotate_size_limit=100M
logrotate_retention=10
logrotate_keep_days=30

[STATS]
goaccess_enable=yes
goaccess_schedule=monthly
goaccess_email=no
goaccess_keep_days=365
EOL

    echo "Logrotate configuration added successfully. Setting logrotate.."
    opencli server-logrotate
fi

}

download_new_admin() {

    mkdir -p $OPENADMIN_DIR
    echo "Updating OpenAdmin from https://github.com/stefanpejcic/openadmin"
    echo ""
    cd $OPENADMIN_DIR
    #stash is used for demo
    git stash
    git pull
    git stash pop

    # need for csf
    chmod +x ${OPENADMIN_DIR}modules/security/csf.pl

    # temp fix for 0.2.5
    if [ -f /etc/debian_version ]; then
        pip3 install --force-reinstall zope.event --break-system-packages
    else
        pip3 install --force-reinstall zope.event
    fi

    mv /etc/openpanel/openadmin/config/terms /etc/openpanel/openadmin/config/terms_accepted_on_update
    
    service admin restart



    echo ""
    echo "Setting service to auto-fill /etc/hosts"
    echo ""
    
    # FOR 0.2.6 ONLY!
    cp -fr /etc/openpanel/services/floatingip.service ${SERVICES_DIR}floatingip.service  > /dev/null 2>&1
    systemctl daemon-reload  > /dev/null 2>&1
    service floatingip start  > /dev/null 2>&1
    systemctl enable floatingip  > /dev/null 2>&1

    
}



uninstall_watcher_service(){
    
    systemctl stop watcher.service
    systemctl disable watcher.service
    service watcher stop
    service watcher disable
    rm -rf /usr/local/admin/scripts/watcher
    rm /etc/systemd/system/watcher.service
    
    systemctl daemon-reload


}


php_fix(){

    for username in $(opencli user-list --json | awk -F'"' '/username/ {print $4}'); do 
      docker exec "$username" bash -c 'sed -i "s/PHP82FPM_STATUS=\"off\"/PHP82FPM_STATUS=\"on\"/g" /etc/entrypoint.sh'
    done


}





update_config_files() {
    echo ""
    echo "Downloading latest OpenPanel configuration from https://github.com/stefanpejcic/openpanel-configuration"
    echo ""

    # Define variables
    CONFIG_DIR="/etc/openpanel"
    DOCKER_COMPOSE_SRC="/etc/openpanel/docker/compose/new-docker-compose.yml"
    DOCKER_COMPOSE_DEST="/root/docker-compose.yml"

    mv /etc/openpanel/ /etc/openpanel024
    mkdir /etc/openpanel
    git clone https://github.com/stefanpejcic/openpanel-configuration /etc/openpanel
    
    echo ""
    echo "Restoring settings from /etc/openpanel024/"
    echo ""

    cp /etc/openpanel024/mysql/db.cnf /etc/openpanel/mysql/db.cnf
    cp /etc/openpanel024/openadmin/users.db /etc/openpanel/openadmin/users.db
    cp /etc/openpanel024/openpanel/conf/openpanel.config /etc/openpanel/openpanel/conf/openpanel.config
    
    echo ""
    echo "Restoring user data and statistics from /etc/openpanel024/"
    echo ""
    
    cp -r /etc/openpanel024/openpanel/core/* /etc/openpanel/openpanel/core
    cp -r /etc/openpanel024/openpanel/websites/ /etc/openpanel/openpanel/websites

    # Copy the new Docker Compose file to the root directory
    if ! cp "$DOCKER_COMPOSE_SRC" "$DOCKER_COMPOSE_DEST"; then
        echo "Error: Failed to copy the Docker Compose file."
        exit 1
    fi
    
}



download_new_panel() {

    mkdir -p $OPENPANEL_DIR
    echo "Downloading latest OpenPanel image from https://hub.docker.com/r/openpanel/openpanel"
    echo ""
    docker pull openpanel/openpanel
}

set_system_cronjob(){

    echo "Updating cronjobs.."
    echo ""
    cp /etc/openpanel/cron /etc/cron.d/openpanel
    chown root:root /etc/cron.d/openpanel
    chmod 0600 /etc/cron.d/openpanel
}


start_certbot(){
    cd /root && docker compose up -d certbot
}



docker_compose_up_with_newer_images(){

  echo "Restarting OpenPanel docker container.."
  echo ""
  docker stop openpanel &&  docker rm openpanel
  echo ""
  cd /root  
  docker compose up -d --no-deps --build openpanel

  #cp version file
  mkdir -p /usr/local/panel/  > /dev/null 2>&1
  docker cp openpanel:/usr/local/panel/version /usr/local/panel/version
}



verify_license() {

    # Get server ipv4
    current_ip=$(curl -s https://ip.openpanel.co || wget -qO- https://ip.openpanel.co)

    echo "Checking OpenPanel license for IP address: $current_ip" 
    echo ""
    server_hostname=$(hostname)

    license_data='{"hostname": "'"$server_hostname"'", "public_ip": "'"$current_ip"'"}'

    response=$(curl -s -X POST -H "Content-Type: application/json" -d "$license_data" https://api.openpanel.co/license-check)

    #echo "Response: $response"
}




celebrate() {

    print_space_and_line

    echo ""
    echo -e "${GREEN}OpenPanel successfully updated to ${NEW_PANEL_VERSION}.${RESET}"
    echo ""

    # remove the unread notification that there is new update
    sed -i 's/UNREAD New OpenPanel update is available/READ New OpenPanel update is available/' $LOG_FILE

    # add notification that update was successful
    write_notification "OpenPanel successfully updated!" "OpenPanel successfully updated from $CURRENT_PANEL_VERSION to $NEW_PANEL_VERSION"
}




temp_for_025(){
    echo -e "\n[!] Backup of previous version is stored in: /etc/openpanel024/"
    echo ""
}


post_install_message() {

    print_space_and_line

    # Instructions for seeking help
    echo -e "\nIf you experience any problems or need further assistance, please do not hesitate to reach out on our community forums or join our Discord server for 
support:"
    echo ""
    echo "👉 Forums: https://community.openpanel.com/"
    echo ""
    echo "👉 Discord: https://discord.openpanel.com/"
    echo ""
    echo "Our community and support team are ready to help you!"
    
    temp_for_025
}



# main execution of the script
main
