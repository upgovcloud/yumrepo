#!/bin/bash
  # File Name:  repopull.sh
  # *** For Ubuntu BASH  ***
  # Created By: Andrew L Goss
  # Created On: 20201208

  # chmod +x repopull.sh
  # bash ./repopull.sh -a 'AWS_ACCESS_KEY' -s 'AWS_SECRET_KEY' - t 'TEAM_NAME'
  # bash ./repopull.sh -a 'XXEEEEE' -s 'XDDGADFDAFDSFDASFSDAFDSFDSF' - t 'upyum'

##  ---------- FUNCTIONS ----------  ##

  CAT NEW YUM REPO FILE
  catRepoFile() {
    echo 'checking to see if /etc/yum.repos.d/${TEAMNAME}.repo is installed.....'
    if [ ! -f /etc/yum.repos.d/${TEAMNAME}.repo ] ; then
      sudo cat > ${TEAMNAME}.repo << 'EOF'
        [${TEAMNAME}]
        baseurl = file:///s3repo/repo/
        enabled = 1
        gpgcheck = 0
        name = ${TEAMNAME}
        repo_gpgcheck = 0
        s3_enabled=1
EOF
      sudo mv ${TEAMNAME}.repo /etc/yum.repos.d/${TEAMNAME}.repo
      echo "/etc/yum.repos.d/${TEAMNAME}.repo has been installed."
    else
      echo "/etc/yum.repos.d/${TEAMNAME}.repo already installed."
    fi
  }


#   configureAWS() {
#     aws configure set aws_access_key_id ${ACCESSKEY}
#     aws configure set aws_secret_access_key ${SECRETKEY}
#     aws configure set region ${REGION}
#   }

  getVars() {
    for i in "${GETVARS[@]}" ; do
      if [[ -z $( eval echo \${$i[0]} ) ]]
        then
          read -p 'This script requires a '${i}', please enter a value: ' ${i}
      else
        echo 'The value for '${i}' is: ' $( eval echo \${$i[0]} )
      fi
    done
  }

  # installAWSCLI2() {
  #   # INSTALL AWS 2
  #   if [ -f /usr/local/bin/aws ] ; then
  #     removeAWSCLI1
  #   else if [ -f /usr/local/bin/aws2 ] ; then
  #     echo "AWS CLI 2 is already Installed."
  #   else
  #     echo 'Navigate to $HOME directory......'
  #       cd ~
  #     echo "Installing AWS CLI 2......"
  #     echo 'Downloading AWS CLI......' 
  #       curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
  #     runit 'Unzip awscliv2.zip' 'unzip awscliv2.zip'
  #     runit 'Install aws' 'sudo ./aws/install'
  #   fi
  #   echo ''
  # }

  # removeAWSCLI1() {
  #   echo "Removing AWS CLI 1......"

  #   # REMOVE ANY LOCAL BIN
  #     echo 'checking to see if /usr/local/aws is installed.....'
  #     if [ ! -f /usr/local/aws ] ; then
  #       echo "/usr/local/aws was found."
  #       runit 'Remove /usr/local/aws' 'sudo rm -rf /usr/local/aws'
  #       echo "/usr/local/aws has been uninstalled."
  #     else
  #       echo "/usr/local/aws was not installed"
  #     fi

  #   # REMOVE ANY LOCAL BIN AWS
  #     echo 'checking to see if /usr/local/bin/aws is installed.....'
  #     if [ ! -f /usr/local/bin/aws ] ; then
  #       echo "/usr/local/bin/aws was found."
  #       runit 'Remove /usr/local/bin/aws' 'sudo rm /usr/local/bin/aws'
  #       echo "/usr/local/bin/aws has been uninstalled."
  #     else
  #       echo "/usr/local/bin/aws was not installed"
  #     fi

  #   echo 'AWS CLI 1 Removed.'
  #   echo ''
  # }

  runit() {
    echo "Attempting ${1}......"
    if ( eval ${2} ); then
      echo ${1}' successful.'
    else
      read -p ${1}' failed.' INPUT
    fi
  }

  # setupInfrastructure() {
  #   # SETUP LOCAL
  #     runit 'Update YUM Repolist' 'yum -y update'
  #     runit 'Upgrade YUM Packages' 'yum -y upgrade'
  #     runit 'Create /s3repo/repo directory' 'mkdir -p /s3repo/repo'
  # }

  # setupRepo() {
  #   # SETUP YUM REPO
  #     runit 'Make /s3repo/repo executable' 'sudo chmod 777 /s3repo/repo'
  #     runit "Sync down s3://${TEAMNAME}repo to /s3repo/repo" "cd /s3repo/repo && aws s3 sync s3://${TEAMNAME}repo . "           
  #     runit 'Rebuid YUM Repo Cache' 'yum clean all' 
  # }

##  ---------- VARIABLES AND ARRAYS ----------  ##
  # Assign Initial Variables
    GETVARS=( 'ACCESSKEY' 'SECRETKEY' 'TEAMNAME' )
    REGION='us-gov-west-1'
    SED=`which sed`

  # Assign Variables Passed Into ./setup.sh
    while getopts "a:s:t:" opt ; do
      [[ ${OPTARG} == -*  ]] && { echo "Missing argument for -${opt}" ; exit 1 ; }
      case ${opt} in
        a) ACCESSKEY=${OPTARG};;
        s) SECRETKEY=${OPTARG};;
        t) TEAMNAME=${OPTARG};;
        \?) echo "Invalid (-${OPTARG}) option";;
        : ) echo "Missing argument for -${OPTARG}";;
      esac
    done

##  ---------- MAIN ----------  ##
  clear
  getVars
  catRepoFile
  # setupInfrastructure
  # removeAWSCLI1
  # installAWSCLI2
  # configureAWS
  # setupRepo
