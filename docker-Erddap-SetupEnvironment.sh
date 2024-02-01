#!/bin/bash
echo ---- BEGIN ERDDAP DEPLOY ---
# Set script working path
ERDDAP_DEPLOYROOTSCRIPT="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
#### DEBUG ####
echo The deploy root script dir is ${ERDDAP_DEPLOYROOTSCRIPT}
read -p "Press any key to start" TMP_ERDDAP_UserInput
#### END DEBUG ####

# Import script variables
echo -n Read variables...
source ${ERDDAP_DEPLOYROOTSCRIPT}/docker-Erddap-SetupEnvVariable.sh
echo DONE!

### Create linux groups ###
echo Create linux groups
groupadd -g ${HOST_ERDDAP_DATA_user_gid} ${HOST_ERDDAP_DATA_user_group}
groupadd -g ${HOST_ERDDAP_Tomcat_user_gid} ${HOST_ERDDAP_Tomcat_user_group}
echo DONE!
### ###
### Create linux users ###
echo Create linux users...

useradd -m -g ${HOST_ERDDAP_DATA_user_group} -u ${HOST_ERDDAP_DATA_user_uid} -s /sbin/nologin ${HOST_ERDDAP_DATA_user} > /dev/null 2>&1
usermod -L ${HOST_ERDDAP_DATA_user} > /dev/null 2>&1
usermod -c ",,,,umask=0002" ${HOST_ERDDAP_DATA_user} > /dev/null 2>&1

useradd -m -g ${HOST_ERDDAP_Tomcat_user_gid} -u ${HOST_ERDDAP_Tomcat_user_uid} -s /sbin/nologin ${HOST_ERDDAP_Tomcat_user} > /dev/null 2>&1
usermod -L ${HOST_ERDDAP_Tomcat_user} > /dev/null 2>&1
usermod -c ",,,,umask=0002" ${HOST_ERDDAP_Tomcat_user} > /dev/null 2>&1

# Add users to additional groups
usermod -a -G ${HOST_ERDDAP_DATA_user_group} ${HOST_ERDDAP_Tomcat_user} > /dev/null 2>&1
echo DONE!
### ###

### Create folders for application docker environment ###
echo Create folders for ERDDAP docker environment...
# Creating the directories tree
mkdir -p ${MYDOCKER_ROOT_DIR}/erddap-docker/{volumes,deployfiles}
mkdir -p ${MYDOCKER_ROOT_DIR}/erddap-docker/volumes/{Content,Data}
mkdir -p ${MYDOCKER_ROOT_DIR}/erddap-docker/deployfiles/erddap-docker
if [ "$ERDDAP_enableTomcatSsl" == "1" ]; then
    mkdir -p ${MYDOCKER_ROOT_DIR}/erddap-docker/volumes/erddapSSLCerts
fi
echo DONE!
# Set directories permissions
echo Set directories permissions...
chmod -R 775 ${MYDOCKER_ROOT_DIR}/erddap-docker/
chmod -R g+s ${MYDOCKER_ROOT_DIR}/erddap-docker/volumes
chmod -R g+s ${MYDOCKER_ROOT_DIR}/erddap-docker/deployfiles

chown -R root:docker ${MYDOCKER_ROOT_DIR}/erddap-docker/volumes
chown -R root:docker ${MYDOCKER_ROOT_DIR}/erddap-docker/deployfiles
chown -R ${HOST_ERDDAP_Tomcat_user}:${HOST_ERDDAP_Tomcat_user_group} ${MYDOCKER_ROOT_DIR}/erddap-docker/volumes/Content
chown -R ${HOST_ERDDAP_Tomcat_user}:${HOST_ERDDAP_Tomcat_user_group} ${MYDOCKER_ROOT_DIR}/erddap-docker/volumes/Data
if [ "$ERDDAP_enableTomcatSsl" == "1" ]; then
    chown -R ${HOST_ERDDAP_Tomcat_user}:${HOST_ERDDAP_Tomcat_user_group} ${MYDOCKER_ROOT_DIR}/erddap-docker/volumes/erddapSSLCerts
fi

# Only fot RedHat-like distribution - Set direcotries context
if command -v yum &> /dev/null
then
    semanage fcontext -a -t container_file_t "${MYDOCKER_ROOT_DIR}/erddap-docker/volumes(/.*)?"
    semanage fcontext -a -t container_share_t "${MYDOCKER_ROOT_DIR}/erddap-docker/deployfiles(/.*)?"
    restorecon -RF ${MYDOCKER_ROOT_DIR}/erddap-docker
fi

echo DONE!
### ###

### Move files and folders in the created directories ###
echo Copy files and folders in the deployfiles directory...
cp -R ${ERDDAP_DEPLOYROOTSCRIPT}/data ${MYDOCKER_ROOT_DIR}/erddap-docker/deployfiles
cp -R ${ERDDAP_DEPLOYROOTSCRIPT}/entrypoints ${MYDOCKER_ROOT_DIR}/erddap-docker/deployfiles
cp -R ${ERDDAP_DEPLOYROOTSCRIPT}/environments ${MYDOCKER_ROOT_DIR}/erddap-docker/deployfiles
echo DONE!

echo Copy files and folders in the volumes directory
if [ "$ERDDAP_enableTomcatSsl" == "1" ]; then
    echo "Being copy of the Tomcat SSL certficate file ($(basename -- $ERDDAP_TomcatSsl_CertPath)). "
    case $ERDDAP_TomcatSsl_CertPath in
        # If the certpath is an absolute path
        /*)
            echo "The given path is an absolute path: ${ERDDAP_TomcatSsl_CertPath}"
            cp $ERDDAP_TomcatSsl_CertPath ${MYDOCKER_ROOT_DIR}/erddap-docker/volumes/erddapSSLCerts/
            ;;
        # If the certpath is a relative path
        *) 
            echo "The given path is an relative path: ${ERDDAP_TomcatSsl_CertPath}"
            cp $ERDDAP_TomcatSsl_CertPath ${MYDOCKER_ROOT_DIR}/erddap-docker/volumes/erddapSSLCerts/
            ;;
    esac
    
fi
echo DONE!
### ###

### Load container default content ###
## ERDDAP ##
echo Set ERDDAP container content values...
# Extract default ERDDAP Content folder (orgin: https://coastwatch.pfeg.noaa.gov/erddap/download/setup.html#initialSetup - https://github.com/BobSimons/erddap/releases/download/v2.12/Content.zip)
#tar xzf ${MYDOCKER_ROOT_DIR}/erddap-docker/deployfiles/data/erddap/content.erddap_v214.tar.gz -C ${MYDOCKER_ROOT_DIR}/erddap-docker/volumes/Content
tar xzf ${MYDOCKER_ROOT_DIR}/erddap-docker/deployfiles/data/erddap/content.erddap_v223.tar.gz -C ${MYDOCKER_ROOT_DIR}/erddap-docker/volumes/Content
chown -R ${HOST_ERDDAP_Tomcat_user}:${HOST_ERDDAP_Tomcat_user} ${MYDOCKER_ROOT_DIR}/erddap-docker/volumes/Content/*
# For ERDDAP version < 2.12
# Set ERDDAP docker environment variable
sed -i "s@<bigParentDirectory>/home/yourName/erddap/</bigParentDirectory>@<bigParentDirectory>${ERDDAP_bigParentDirectory}</bigParentDirectory>@g" ${MYDOCKER_ROOT_DIR}/erddap-docker/volumes/Content/setup.xml
sed -i "s@<baseUrl>http://localhost:8080</baseUrl>@<baseUrl>${ERDDAP_baseUrl}</baseUrl>@g" ${MYDOCKER_ROOT_DIR}/erddap-docker/volumes/Content/setup.xml
sed -i "s@<baseHttpsUrl></baseHttpsUrl>@<baseHttpsUrl>${ERDDAP_baseHttpsUrl}</baseHttpsUrl>@g" ${MYDOCKER_ROOT_DIR}/erddap-docker/volumes/Content/setup.xml
sed -i "s|<emailEverythingTo>your.email@yourInstitution.edu</emailEverythingTo>|<emailEverythingTo>${ERDDAP_emailEverythingTo}</emailEverythingTo>|g" ${MYDOCKER_ROOT_DIR}/erddap-docker/volumes/Content/setup.xml
sed -i "s@<adminInstitution>Your Institution</adminInstitution>@<adminInstitution>${ERDDAP_adminInstitution}</adminInstitution>@" ${MYDOCKER_ROOT_DIR}/erddap-docker/volumes/Content/setup.xml
sed -i "s@<adminInstitutionUrl>Your Institution's or Group's Url</adminInstitutionUrl>@<adminInstitutionUrl>${ERDDAP_adminInstitutionUrl}</adminInstitutionUrl>@" ${MYDOCKER_ROOT_DIR}/erddap-docker/volumes/Content/setup.xml
sed -i "s@<adminIndividualName>Your Name</adminIndividualName>@<adminIndividualName>${ERDDAP_adminIndividualName}</adminIndividualName>@" ${MYDOCKER_ROOT_DIR}/erddap-docker/volumes/Content/setup.xml
sed -i "s@<adminPosition>ERDDAP administrator</adminPosition>@<adminPosition>${ERDDAP_adminPosition}</adminPosition>@" ${MYDOCKER_ROOT_DIR}/erddap-docker/volumes/Content/setup.xml
sed -i "s@<adminPhone>+1 999-999-9999</adminPhone>@<adminPhone>${ERDDAP_adminPhone}</adminPhone>@" ${MYDOCKER_ROOT_DIR}/erddap-docker/volumes/Content/setup.xml
sed -i "s@<adminAddress>123 Main St.</adminAddress>@<adminAddress>${ERDDAP_adminAddress}</adminAddress>@" ${MYDOCKER_ROOT_DIR}/erddap-docker/volumes/Content/setup.xml
sed -i "s@<adminCity>Some Town</adminCity>@<adminCity>${ERDDAP_adminCity}</adminCity>@" ${MYDOCKER_ROOT_DIR}/erddap-docker/volumes/Content/setup.xml
sed -i "s@<adminStateOrProvince>CA</adminStateOrProvince>@<adminStateOrProvince>${ERDDAP_adminStateOrProvince}</adminStateOrProvince>@" ${MYDOCKER_ROOT_DIR}/erddap-docker/volumes/Content/setup.xml
sed -i "s@<adminPostalCode>99999</adminPostalCode>@<adminPostalCode>${ERDDAP_adminPostalCode}</adminPostalCode>@" ${MYDOCKER_ROOT_DIR}/erddap-docker/volumes/Content/setup.xml
sed -i "s@<adminCountry>USA</adminCountry>@<adminCountry>${ERDDAP_adminCountry}</adminCountry>@" ${MYDOCKER_ROOT_DIR}/erddap-docker/volumes/Content/setup.xml
sed -i "s|<adminEmail>your.email@yourCompany.com</adminEmail>|<adminEmail>${ERDDAP_adminemail}</adminEmail>|" ${MYDOCKER_ROOT_DIR}/erddap-docker/volumes/Content/setup.xml
sed -i "s@<flagKeyKey>CHANGE THIS TO YOUR FAVORITE QUOTE</flagKeyKey>@<flagKeyKey>${ERDDAP_flagKeyKey}</flagKeyKey>@" ${MYDOCKER_ROOT_DIR}/erddap-docker/volumes/Content/setup.xml

if [ $ERDDAP_SetMailParameters -eq 1 ]; then
    sed -i "s|<emailFromAddress>your.email@yourCompany.com</emailFromAddress>|<emailFromAddress>${ERDDAP_emailFromAddress}</emailFromAddress>|" ${MYDOCKER_ROOT_DIR}/erddap-docker/volumes/Content/setup.xml
    sed -i "s|<emailUserName>your.email@yourCompany.com</emailUserName>|<emailUserName>${ERDDAP_emailUserName}</emailUserName>|" ${MYDOCKER_ROOT_DIR}/erddap-docker/volumes/Content/setup.xml
    sed -i "s|<emailPassword>yourPassword</emailPassword>@<emailPassword>${ERDDAP_emailPassword}</emailPassword>|" ${MYDOCKER_ROOT_DIR}/erddap-docker/volumes/Content/setup.xml
    sed -i "s|<emailProperties></emailProperties>|<emailProperties>${ERDDAP_emailProperties}</emailProperties>|" ${MYDOCKER_ROOT_DIR}/erddap-docker/volumes/Content/setup.xml
    sed -i "s|<emailSmtpHost>your.smtp.host.edu</emailSmtpHost>|<emailSmtpHost>${ERDDAP_emailSmtpHost}</emailSmtpHost>|" ${MYDOCKER_ROOT_DIR}/erddap-docker/volumes/Content/setup.xml
    sed -i "s|<emailSmtpPort>25</emailSmtpPort>|<emailSmtpPort>${ERDDAP_emailSmtpPort}</emailSmtpPort>|" ${MYDOCKER_ROOT_DIR}/erddap-docker/volumes/Content/setup.xml
else
    echo "The ERDDAP mail parameters will be not configured, as you specified (ERDDAP_SetMailParameters=$ERDDAP_SetMailParameters)."
fi

echo "ERDDAP_MIN_MEMORY=\"${ERDDAP_MIN_MEMORY}\"" >> ${MYDOCKER_ROOT_DIR}/erddap-docker/deployfiles/environments/erddap-compose.env
echo "ERDDAP_MAX_MEMORY=\"${ERDDAP_MAX_MEMORY}\"" >> ${MYDOCKER_ROOT_DIR}/erddap-docker/deployfiles/environments/erddap-compose.env
# For ERDDAP version >= 2.14
# Set ERDDAP docker environment variable
echo "Setup ERDDAP_* Environment variables for custom configurations..."
echo "" >> ${MYDOCKER_ROOT_DIR}/erddap-docker/deployfiles/environments/erddap-compose.env
echo "# ERDDAP VARIABLES" >> ${MYDOCKER_ROOT_DIR}/erddap-docker/deployfiles/environments/erddap-compose.env
echo "ERDDAP_bigParentDirectory=\"${ERDDAP_bigParentDirectory}\"" >> ${MYDOCKER_ROOT_DIR}/erddap-docker/deployfiles/environments/erddap-compose.env
echo "ERDDAP_baseUrl=\"${ERDDAP_baseUrl}\"" >> ${MYDOCKER_ROOT_DIR}/erddap-docker/deployfiles/environments/erddap-compose.env
echo "ERDDAP_baseHttpsUrl=\"${ERDDAP_baseHttpsUrl}\"" >> ${MYDOCKER_ROOT_DIR}/erddap-docker/deployfiles/environments/erddap-compose.env
echo "ERDDAP_emailEverythingTo=\"${ERDDAP_emailEverythingTo}\"" >> ${MYDOCKER_ROOT_DIR}/erddap-docker/deployfiles/environments/erddap-compose.env
echo "DONE!"

# If ERDDAP_enableTomcatSsl is equal to 1, we setup the Tomcat bind to server.sslconnetor.xml and the certificate
if [ "$ERDDAP_enableTomcatSsl" == "1" ]; then
    # Set server.sslconnetor.xml parameters
    ERDDAP_TomcatSsl_CertPath_Filename="$(basename -- $ERDDAP_TomcatSsl_CertPath)"
    sed -i "s@ph_KEYSTORE_FILENAME@${ERDDAP_TomcatSsl_CertPath_Filename}@g" ${MYDOCKER_ROOT_DIR}/erddap-docker/deployfiles/data/tomcat/server.sslconnetor.xml
    sed -i "s@ph_KEYSTORE_TYPE@${ERDDAP_TomcatSsl_CertType}@g" ${MYDOCKER_ROOT_DIR}/erddap-docker/deployfiles/data/tomcat/server.sslconnetor.xml
    sed -i "s@ph_KEYSTORE_PASSWORD@${ERDDAP_TomcatSsl_CertPassword}@g" ${MYDOCKER_ROOT_DIR}/erddap-docker/deployfiles/data/tomcat/server.sslconnetor.xml
fi
## ##

echo DONE!
## ##
### ###

### Set docker-compose file ###
echo Set the docker-compose files parameters...
## ERDDAP ##
cp ${ERDDAP_DEPLOYROOTSCRIPT}/templates/docker-compose.yaml.template ${MYDOCKER_ROOT_DIR}/erddap-docker/deployfiles/erddap-docker/docker-compose.yaml
sed -i "s@ph_ERDDAP_Container_Name@${ERDDAP_Container_Name}@g" ${MYDOCKER_ROOT_DIR}/erddap-docker/deployfiles/erddap-docker/docker-compose.yaml
sed -i "s@ph_MYDOCKER_ERDDAP_HOST_PORT@${MYDOCKER_ERDDAP_HOST_PORT}@g" ${MYDOCKER_ROOT_DIR}/erddap-docker/deployfiles/erddap-docker/docker-compose.yaml
sed -i "s@ph_MYDOCKER_ERDDAP_ENVIRONMENT_FILE@${MYDOCKER_ROOT_DIR}/erddap-docker/deployfiles/environments/erddap-compose.env@g" ${MYDOCKER_ROOT_DIR}/erddap-docker/deployfiles/erddap-docker/docker-compose.yaml
sed -i "s@ph_MYDOCKER_ERDDAP_DATA@${MYDOCKER_ROOT_DIR}/erddap-docker/volumes/Data@g" ${MYDOCKER_ROOT_DIR}/erddap-docker/deployfiles/erddap-docker/docker-compose.yaml
sed -i "s@ph_MYDOCKER_ERDDAP_CONTENT@${MYDOCKER_ROOT_DIR}/erddap-docker/volumes/Content@g" ${MYDOCKER_ROOT_DIR}/erddap-docker/deployfiles/erddap-docker/docker-compose.yaml
sed -i "s@ph_MYDOCKER_EXT_DATA_DIR@${MYDOCKER_EXT_DATA_DIR}@g" ${MYDOCKER_ROOT_DIR}/erddap-docker/deployfiles/erddap-docker/docker-compose.yaml
sed -i "s@ph_MYDOCKER_ERDDAP_ENTRYPOINT@${MYDOCKER_ROOT_DIR}/erddap-docker/deployfiles/entrypoints/erddap_entrypoint.sh@g" ${MYDOCKER_ROOT_DIR}/erddap-docker/deployfiles/erddap-docker/docker-compose.yaml
# If ERDDAP_enableTomcatSsl is equal to 1, we setup the Tomcat bind to server.sslconnetor.xml and the certificate
## We need to mount the server.sslconnetor.xml inside the container because we have to copy it's content in the server.xml file. The copy happend through the entrypoint.
## We cannot mount ther sever.xml because other wise it cannot be modified insiede the container with command like sed.
if [ "$ERDDAP_enableTomcatSsl" == "1" ]; then
    # Copy the content of the Tomcat SSL yaml template
    sed -i -e "/# ERDDAP_ScriptPortsPinPoint/r ${ERDDAP_DEPLOYROOTSCRIPT}/templates/docker-compose.tomcatSsl_ports.yaml.template" ${MYDOCKER_ROOT_DIR}/erddap-docker/deployfiles/erddap-docker/docker-compose.yaml
    sed -i -e "/# ERDDAP_ScriptVolumePinPoint/r ${ERDDAP_DEPLOYROOTSCRIPT}/templates/docker-compose.tomcatSsl_volumes.yaml.template" ${MYDOCKER_ROOT_DIR}/erddap-docker/deployfiles/erddap-docker/docker-compose.yaml
    # Set the placeholders
    sed -i "s@ph_MYDOCKER_ERDDAP_HOST_PORT_SSL@${MYDOCKER_ERDDAP_HOST_PORT_SSL}@g" ${MYDOCKER_ROOT_DIR}/erddap-docker/deployfiles/erddap-docker/docker-compose.yaml
    ERDDAP_TomcatSsl_CertPath_Filename="$(basename -- $ERDDAP_TomcatSsl_CertPath)"
    sed -i "s@ph_ERDDAP_TomcatSsl_CertPath@${MYDOCKER_ROOT_DIR}/erddap-docker/volumes/erddapSSLCerts/${ERDDAP_TomcatSsl_CertPath_Filename}@g" ${MYDOCKER_ROOT_DIR}/erddap-docker/deployfiles/erddap-docker/docker-compose.yaml
    sed -i "s@ph_KEYSTORE_FILENAME@${ERDDAP_TomcatSsl_CertPath_Filename}@g" ${MYDOCKER_ROOT_DIR}/erddap-docker/deployfiles/erddap-docker/docker-compose.yaml
    sed -i "s@ph_MYDOCKER_ERDDAP_TOMCAT_SERVER_XML@${MYDOCKER_ROOT_DIR}/erddap-docker/deployfiles/data/tomcat/server.sslconnetor.xml@g" ${MYDOCKER_ROOT_DIR}/erddap-docker/deployfiles/erddap-docker/docker-compose.yaml
fi
## ##
echo DONE!
### ###

### Set environments files ###
# ERDDAP
## Tomcat User and Group
sed -i "s@ph_HOST_ERDDAP_Tomcat_user_uid@${HOST_ERDDAP_Tomcat_user_uid}@g" ${MYDOCKER_ROOT_DIR}/erddap-docker/deployfiles/environments/erddap-compose.env
sed -i "s@ph_HOST_ERDDAP_Tomcat_user_gid@${HOST_ERDDAP_Tomcat_user_gid}@g" ${MYDOCKER_ROOT_DIR}/erddap-docker/deployfiles/environments/erddap-compose.env
##
### ###

### Set Entrypoint ###
echo Set entrypoints
### Set Tomcat value in erddap_entrypoint.sh script ###
sed -i "s@ph_HOST_ERDDAP_DATA_user_uid@${HOST_ERDDAP_DATA_user_uid}@g" ${MYDOCKER_ROOT_DIR}/erddap-docker/deployfiles/entrypoints/erddap_entrypoint.sh
sed -i "s@ph_HOST_ERDDAP_DATA_user_group@${HOST_ERDDAP_DATA_user_group}@g" ${MYDOCKER_ROOT_DIR}/erddap-docker/deployfiles/entrypoints/erddap_entrypoint.sh
sed -i "s@ph_HOST_ERDDAP_DATA_user_gid@${HOST_ERDDAP_DATA_user_gid}@g" ${MYDOCKER_ROOT_DIR}/erddap-docker/deployfiles/entrypoints/erddap_entrypoint.sh
sed -i "s@ph_HOST_ERDDAP_DATA_user@${HOST_ERDDAP_DATA_user}@g" ${MYDOCKER_ROOT_DIR}/erddap-docker/deployfiles/entrypoints/erddap_entrypoint.sh
# If ERDDAP_enableTomcatSsl is equal to 1, we setup the entrypoint to add the SSL Connector
if [ "$ERDDAP_enableTomcatSsl" == "1" ]; then
    #sed -i 's@# ETT SSL Connector placeholder@sed -i -e \"/<Service name=\\ \"Catalina\\ \">/r \${CATALINA_HOME}/conf/server.sslconnetor.xml\" \${CATALINA_HOME}/conf/server.xml@g' ${MYDOCKER_ROOT_DIR}/erddap-docker/deployfiles/erddap-docker/entrypoints/erddap_entrypoint.sh
    sed -i -e "/# ETT SSL Connector placeholder/r ${ERDDAP_DEPLOYROOTSCRIPT}/entrypoints/erddap_entrypoint_sslconnector.toinclude" ${MYDOCKER_ROOT_DIR}/erddap-docker/deployfiles/entrypoints/erddap_entrypoint.sh
fi
### Set ERDDAP permission erddap_entrypoint.sh file ###
chown ${HOST_ERDDAP_Tomcat_user}:${HOST_ERDDAP_Tomcat_user} ${MYDOCKER_ROOT_DIR}/erddap-docker/deployfiles/entrypoints/erddap_entrypoint.sh
chmod 775 ${MYDOCKER_ROOT_DIR}/erddap-docker/deployfiles/entrypoints/erddap_entrypoint.sh
echo DONE!
### ###

### ERDDAP Reminder for password configuration ###
if [ $ERDDAP_SetMailParameters -eq 1 ]; then
    if [ -z "$MYDOCKER_GEONETWORK_IMAGE" ]
    then
        echo "!!! Remember to set the ERDDAP SMTP password in the ${MYDOCKER_ROOT_DIR}/erddap-docker/volumes/Content/setup.xml file."
    fi
fi
### ###