### HOST VARIABLES
# This is the user used by ERDDAP to access the MYDOCKER_DATA_DIR
HOST_ERDDAP_DATA_user="usrerddap"
HOST_ERDDAP_DATA_user_uid="2000"
HOST_ERDDAP_DATA_user_group="usrerddap"
HOST_ERDDAP_DATA_user_gid="2000"

# this is the user used by ERDDAP to access the Tomcat volumes
HOST_ERDDAP_Tomcat_user="usrtomcat"
HOST_ERDDAP_Tomcat_user_uid="2001"
HOST_ERDDAP_Tomcat_user_group="usrtomcat"
HOST_ERDDAP_Tomcat_user_gid="2001"

### DOCKER
# this folder where are created all the deployment directories.
MYDOCKER_ROOT_DIR="/opt/data00/customdocker"
# this is folder where you put external data accessible by ERDDAP
MYDOCKER_EXT_DATA_DIR="/opt/data00/appdata"
# this is the port used by the container
MYDOCKER_ERDDAP_HOST_PORT="12081"
# this is the port used by the container if you enable SSL in the variables below
MYDOCKER_ERDDAP_HOST_PORT_SSL="12082"

### ERDDAP VARIABLES
# Environment Variables - Starting with ERDDAP v2.14, ERDDAP administrators can override any value in setup.xml by specifying an environment variable named ERDDAP_valueName before running ERDDAP
# bigParentDirectory - Same as volume mounted in the container
ERDDAP_bigParentDirectory="/erddapData"
# This set the domain or IPv4 at ERDDAP will be visible.
ERDDAP_webDomainOrIPv4="www.example.com"
# baseUrl - Same as the URL that you setup in the web proxy that handle the comunication with the container
ERDDAP_baseUrl="http://${ERDDAP_webDomainOrIPv4}"
# baseUrl - Same as the URL that you setup in the web proxy that handle the SSL comunication with the container
ERDDAP_baseHttpsUrl="https://${ERDDAP_webDomainOrIPv4}"
# This is the container name for the docker-compose
ERDDAP_Container_Name="erddap-ett"
## Do you want to enable SSL in the ERDDAP Tomcat container ? (0 = no, 1 = yes)
ERDDAP_enableTomcatSsl=1
## You must supply a PFX cert store
## Set the path to the certificate - Here we set a selfsigned certificate that is in erddap/data/erddap/ssl.
ERDDAP_TomcatSsl_CertPath="erddap/data/erddap/ssl/erddap-self.localhost_2122.pfx"
## Set the certificate store type. You have to specify the certificate algorithm. NOT the certificate\keystore type (JKS or PCK12).
ERDDAP_TomcatSsl_CertType="RSA"
## Set the certificate store password - NOT USE @ in the password
ERDDAP_TomcatSsl_CertPassword="ErddapSelfCert123!"
##
# CHANGE THE FOLLOWING VARIABLES
ERDDAP_emailEverythingTo="asd@asd.com"
ERDDAP_adminInstitution="ETT S.p.A. - People and Technology"
ERDDAP_adminInstitutionUrl="https://www.ettsolutions.com/"
ERDDAP_adminIndividualName="ETT Ricerca"
ERDDAP_adminPosition="ERDDAP administrator"
ERDDAP_adminPhone="+39 010 6519116"
ERDDAP_adminAddress="Via Sestri 37"
ERDDAP_adminCity="GENOVA"
ERDDAP_adminStateOrProvince="GE"
ERDDAP_adminPostalCode="16154"
ERDDAP_adminCountry="ITALY"
ERDDAP_adminemail="ricerca.innovazione.ett@ettsolutions.com"
ERDDAP_flagKeyKey="CHANGE ME!"
# OPTIONAL - Set ERDDAP mail parameters
# This enable (1) or disable (0) the mail parameters configuration
ERDDAP_SetMailParameters=0
ERDDAP_emailFromAddress=""
ERDDAP_emailUserName=""
# If you use the '|' in the password, than leave the variable blank and set the parameters when the configuration is finished.
ERDDAP_emailPassword=""
ERDDAP_emailProperties=""
ERDDAP_emailSmtpHost=""
ERDDAP_emailSmtpPort=""
# these variables set the minimum and maximum memory available in ERDDAP, set by default at 4 GigaBytes
ERDDAP_MIN_MEMORY="4G"
ERDDAP_MAX_MEMORY="4G"
###