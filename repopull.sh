#!/bin/bash
  # File Name:  repopull.sh
  # *** For Ubuntu BASH  ***
  # Created By: Andrew L Goss
  # Created On: 20201208

  # chmod +x repopull.sh
  # bash ./repopull.sh -a 'AWS_ACCESS_KEY' -s 'AWS_SECRET_KEY' - t 'TEAM_NAME'
  # bash ./repopull.sh -a 'XXEEEEE' -s 'XDDGADFDAFDSFDASFSDAFDSFDSF' - t 'upyum'

##  ---------- FUNCTIONS ----------  ##

  catRepoFile() {
  # CAT NEW YUM REPO FILE    
    echo "Checking to see if /etc/yum.repos.d/${TEAMNAME}.repo is installed....."
    if [ ! -f /etc/yum.repos.d/${TEAMNAME}.repo ] ; then
      sudo tee "/etc/yum.repos.d/${TEAMNAME}.repo" > /dev/null <<EOF
[${TEAMNAME}]
baseurl = file:///${TEAMNAME}/
enabled = 1
gpgcheck = 0
name = ${TEAMNAME}
EOF
      echo "/etc/yum.repos.d/${TEAMNAME}.repo has been installed."
      runit "Removing whitespace from /etc/yum.repos.d/${TEAMNAME}.repo" "sudo ${SED} -i -e 's/[ \t]*//' /etc/yum.repos.d/${TEAMNAME}.repo"
    else
      echo "/etc/yum.repos.d/${TEAMNAME}.repo already installed."
    fi
    echo ''
  }

  configureAWS() {
    aws configure set aws_access_key_id ${ACCESSKEY}
    aws configure set aws_secret_access_key ${SECRETKEY}
    aws configure set region ${REGION}
    echo ''
  }

  getVars() {
    for i in "${GETVARS[@]}" ; do
      if [[ -z $( eval echo \${$i[0]} ) ]]
        then
          read -p 'This script requires a '${i}', please enter a value: ' ${i}
      else
        echo 'The value for '${i}' is: ' $( eval echo \${$i[0]} )
      fi
    done
    echo ''
  }

  installAWSCLI2() {
    # INSTALL AWS 2
    if [ -f /usr/local/bin/aws ] ; then
      removeAWSCLI1
    elif [ -f /usr/local/bin/aws2 ] ; then
      echo "AWS CLI 2 is already Installed."
    else
      echo 'Navigate to $HOME directory......'
        cd ~
      echo "Installing AWS CLI 2......"
      echo 'Downloading AWS CLI......' 
        curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
      runit 'Unzip awscliv2.zip' 'unzip -o awscliv2.zip'
      runit 'Install aws' 'sudo ./aws/install --update'
      runit 'Verify aws version' 'aws --version'
    fi
    echo ''
  }

  removeAWSCLI1() {
    echo "Removing AWS CLI 1......"
    for i in "${AWSVARS[@]}" ; do
      echo "Looking for ${i}......"
      if [[ -f "${i}" ]] || [[ -d "${i}" ]] ; then
        echo "${i} was found."
        runit "Remove ${i}" "sudo rm -rf ${i}"
      else
        echo "${i} was not installed."
      fi
    done
    echo 'AWS CLI 1 Removed.'
    echo ''
  }

  runit() {
    echo "Attempting ${1}......"
    if ( eval ${2} ); then
      echo ${1}' successful.'
    else
      read -p ${1}' failed.' INPUT
    fi
  }

  setupInfrastructure() {
    # SETUP LOCAL
      runit 'Install createrepo and wget' 'sudo yum -y install createrepo wget'
      runit "Create /${TEAMNAME} directory" "sudo mkdir -p /${TEAMNAME}"
      echo ''
  }

  setupRepo() {
    # SETUP YUM REPO
      runit "Make /${TEAMNAME}/repo executable" "sudo chmod 777 /${TEAMNAME}"
      runit "Sync down s3://${TEAMNAME}repo to /${TEAMNAME}" "cd /${TEAMNAME} && aws s3 sync s3://${TEAMNAME}repo . "
      runit 'Make /${TEAMNAME} executable' 'sudo chmod 777 /${TEAMNAME}'
      runit "Update /${TEAMNAME}" "sudo createrepo --update /${TEAMNAME}"       
      runit 'Rebuid YUM Repo Cache' 'yum clean all && yum makecache' 
      echo ''
  }

##  ---------- VARIABLES AND ARRAYS ----------  ##
  # Assign Initial Variables
    AWSVARS=( "${HOME}/aws"  '/usr/bin/aws' '/usr/local/aws-cli/' '/usr/local/aws' '/usr/local/bin/aws' )
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
  setupInfrastructure  
  catRepoFile
  removeAWSCLI1
  installAWSCLI2
  configureAWS
  setupRepo
