#This is the ERDDAP version to install
ERDDAP_VERSION="2.27.0"

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
MYDOCKER_ROOT_DIR="/mnt/c/opt/data00/customdocker"
# this is folder where you put external data accessible by ERDDAP
MYDOCKER_EXT_DATA_DIR="/mnt/c/opt/data00/appdata"
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
ERDDAP_TomcatSsl_CertPath="data/erddap/ssl/erddap-self.localhost_2122.pfx"
## Set the certificate store type. You have to specify the certificate algorithm. NOT the certificate\keystore type (JKS or PCK12).
ERDDAP_TomcatSsl_CertType="RSA"
## Set the certificate store password - NOT USE @ in the password
ERDDAP_TomcatSsl_CertPassword="ErddapSelfCert123!"


#######CHANGE AS NEEDED
#JAVA MEMORY CONFIGURATION
ERDDAP_MIN_MEMORY=1G 
ERDDAP_MAX_MEMORY=4G
###CONFIGURATION WITH DEFAULT VALUES
#change ERDDAP_baseUrl and ERDDAP_baseHttpsUrl to your ERDDAP server's URL
ERDDAP_baseUrl='http://localhost:12081'
ERDDAP_baseHttpsUrl=''
ERDDAP_flagKeyKey='flagKeyKey put any string you want here'
ERDDAP_emailEverythingTo='changethisto@youremailaddress.com'
ERDDAP_emailDailyReportsTo=''
ERDDAP_emailFromAddress='change this to your email address'
ERDDAP_emailUserName='change this to your email user name'
ERDDAP_emailPassword='change this to your email password'
ERDDAP_emailSmtpHost='change this to your email smtp host'
ERDDAP_emailSmtpPort='change this to your email smtp port'
ERDDAP_adminInstitution='change this to your institution name'
ERDDAP_adminInstitutionUrl='http://changethisto.yourinstitutionurl.com'
ERDDAP_adminIndividualName='change this to your name'
ERDDAP_adminPosition='change this to your position'
ERDDAP_adminPhone='change this to your phone number'
ERDDAP_adminAddress='change this to your address'
ERDDAP_adminCity='change this to your city'
ERDDAP_adminStateOrProvince='change this to your state or province'
ERDDAP_adminPostalCode='change this to your postal code'
ERDDAP_adminCountry='change this to your country'
ERDDAP_adminEmail='changethisto@youremailaddress.com'
ERDDAP_subscribeToRemoteErddapDataset='true'
ERDDAP_fontFamily='DejaVu Sans'
ERDDAP_logMaxSizeMB='20'
ERDDAP_datasetsRegex='.*'
ERDDAP_quickRestart='true'
ERDDAP_authentication=''
ERDDAP_googleClientID=''
ERDDAP_orcidClientID=''
ERDDAP_orcidClientSecret=''
ERDDAP_passwordEncoding='UEPSHA256'
ERDDAP_listPrivateDatasets='false'
ERDDAP_searchEngine='original'
ERDDAP_accessConstraints='NONE'
ERDDAP_accessRequiresAuthorization='only accessible to authorized users'
ERDDAP_fees='NONE'
ERDDAP_keywords='earth science, atmosphere, ocean, biosphere, biology, environment'
ERDDAP_units_standard='UDUNITS'
ERDDAP_fgdcActive='true'
ERDDAP_iso19115Active='true'
ERDDAP_filesActive='true'
ERDDAP_defaultAccessibleViaFiles='true'
ERDDAP_dataProviderFormActive='true'
ERDDAP_subscriptionSystemActive='true'
ERDDAP_convertersActive='true'
ERDDAP_slideSorterActive='true'
ERDDAP_highResLogoImageFile='noaa_simple.gif'
ERDDAP_lowResLogoImageFile='noaa20.gif'
ERDDAP_googleEarthLogoFile='nlogo.gif'
ERDDAP_variablesMustHaveIoosCategory='false'
ERDDAP_categoryAttributes='global:cdm_data_type, global:institution, ioos_category, global:keywords, long_name, standard_name, variableName'
ERDDAP_useSharedWatchService='true'
ERDDAP_useSaxParser='true'
ERDDAP_cacheClearMinutes='15'
ERDDAP_useHeadersForUrl='true'
ERDDAP_useSisISO19115='true'
ERDDAP_updateSubsRssOnFileChanges='true'
ERDDAP_includeNcCFSubsetVariables='false'
ERDDAP_redirectDocumentationToGitHubIo='true'
ERDDAP_showLoadErrorsOnStatusPage='true'