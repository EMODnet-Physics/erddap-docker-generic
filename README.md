# DOCKER DEPLOY - ERDDAP
You can deploy the basic structure of environment using the script `docker-Erddap-SetupEnvVariable.sh`.  
The enviroment created contains: 

* docker-compose - ERDDAP image set is axiom/docker-erddap:2.23-jdk17-openjdk  
* ERDDAP container - Exposed on port set with the variable `MYDOCKER_ERDDAP_HOST_PORT`. Now it's set to 12081. Evantually also the `MYDOCKER_ERDDAP_HOST_PORT_SSL`.
* ext data directory - This directory on the host could have data that will be accessible from the ERDDAP container.
* ERDDAP Data directory - This is the directory on the host where are ERDDAP Data files (cache, logs, etc...).
* ERDDAP Content directory - This is the directory on the host where are ERDDAP Content files (configuration files).
* `HOST_ERDDAP_DATA_user` -  The user that is used for access the ext data directory.
*  `HOST_ERDDAP_Tomcat_user` - The user that is used from the docker to run the container application and writing in the persistent volumes.
  
WARNING: This script doesn't do any check of the variables content. So be careful when you change their value.

## Prerequisites
* Host OS - Linux Ubutu or Centos (see NOTE section for other Linux OS).
* The `HOST_ERDDAP_DATA_user`, `HOST_ERDDAP_DATA_user_group`, `HOST_ERDDAP_Tomcat_user` and `HOST_ERDDAP_Tomcat_user_group` names, UIDs and GIDs must be free or already used from the same users and groups.
* `MYDOCKER_ROOT_DIR` - Will be the folder where are created all the deployement directories.
* Host port `MYDOCKER_ERDDAP_HOST_PORT` is usable - It will be used from the ERDDAP container. It will forward request to the ERDDAP container port 8080. By default is set to 12081.
    * Same for the host port `MYDOCKER_ERDDAP_HOST_PORT_SSL` 
* Access to the *root* user
* Docker must be already installed
* If you plan to use Apache for proxing the request to this container, this modules must be installed: proxy, proxy_http, rewrite, ssl and headers.

## HOW TO USE
1. Login as *root* user.
2. Copy al the content from this repository in any folder of the host. For example `/root/deploy`. 
3. Enter in the directory with the `docker-EnvCreation.sh` file.
4. Customize the configuration in the `docker-EnvCreationVariable.sh` and `docker-EnvCreationVariableNcwms.sh` files. The minimal changes you have to do are:
    1. `HOST_ERDDAP_DATA_*`
    2. `HOST_ERDDAP_Tomcat_*`
    3. `MYDOCKER_ROOT_DIR`
    4. `MYDOCKER_EXT_DATA_DIR`
    5. `ERDDAP_webDomainOrIPv4`
    6. `ERDDAP_Container_Name`
    4. `ERDDAP_emailEverythingTo`
    5. `ERDDAP_admin*` - Use the *@* only in the email fields.
    6. `ERDDAP_flagKeyKey` - Do no use the *@* char
5. OPTIONAL - Change the docker image in `templates/docker-compose.yaml.template`. Now is set to `axiom/docker-erddap:2.23-jdk17-openjdk`
    * NOTE - From ERDDAP 2.20 it use Tomcat 10. So we have changed the SSL connector. If you plan to use an ERDDAP image below 2.20 version, you have to change also the Tomcat SSL connector. This is explained in dedicated chapter.
    * NOTE - ERDDAP Content - After the first deploy, also remember ti change the content of the folder `${MYDOCKER_ROOT_DIR}/erddap-docker/volumes/Content` with the file from the compressed file given by the ERDDAP maintainer. You can find them in the `data/erddap` directory of this repository or on their site: `https://coastwatch.pfeg.noaa.gov/erddap/download/setup.html`
6. Give the permissions *Execute* (chmod +x) to `docker-EnvCreation.sh` file.
7. Run `docker-EnvCreation.sh` and follow instruction on terminal.

## NOTE
### To execute GenerateDatasetsXml
docker exec -it erddap-docker_erddap_1 bash -c "cd webapps/erddap/WEB-INF/ && bash GenerateDatasetsXml.sh -verbose"

In the docker image the `MYDOCKER_DATA_DIR` is mounted in the `/Data/` path

### OS other than CentOS
#### SELinux
For OS that doesn't have se SELinux, from `docker-EnvCreation.sh` remove the lines 

    # Only fot RedHat-like distribution - Set direcotries context
    semanage fcontext -a -t container_file_t "${MYDOCKER_ROOT_DIR}/opt/customdocker/customvolumes(/.*)?"
    semanage fcontext -a -t container_share_t "${MYDOCKER_ROOT_DIR}/opt/customdocker/deployfiles(/.*)?"
    restorecon -RF ${MYDOCKER_ROOT_DIR}/opt/customdocker

#### Change Tomcat SSL connector 
From Tomcat 10 some SSL connector parameters are changed. So we have changed the configuration file in `data/tomcat/server.sslconnetor.xml` accordingly.
The old configuration is in the file `data/tomcat/server.sslconnetor.tomcat8.xml`.
So if you have to use an ERDDAP image that user Tomcat 8 (like 2.18), you must:

* ERDDAP Container is already deployed ?
    * NO
    Rename the file 
    `data/tomcat/server.sslconnetor.xml` to `data/tomcat/server.sslconnetor.tomcat10.xml`
    `data/tomcat/server.sslconnetor.tomcat8.xml` to `data/tomcat/server.sslconnetor.tomcat.xml`
    than run the creation script.
    * YES
    Go in the `<YOU_DEPLOY_DIR>/data/tomcat/` of your deploy. Rename the file 
    `<YOU_DEPLOY_DIR>/data/tomcat/server.sslconnetor.xml` to `<YOU_DEPLOY_DIR>/data/tomcat/server.sslconnetor.tomcat8.xml`
    copy`data/tomcat/server.sslconnetor.xml` to `<YOU_DEPLOY_DIR>/data/tomcat/`
    Change the value of the placeholders (ph_*) with the value in the old file.
    Then recreate the docker so the new configuration will applied.

### JAVA_OPTS
From Java 17 it's not supported the paraameter `-XX:+UseConcMarkSweepGC`. So we have remove it from the Envorioment files (`environments/erddap-compose.env`).

## TROUBLESHOOT
### Apache - Website not accessible
Check if the vhost is loaded correctly. If there are other vhost, maybe they have the same domain or IPv4.

