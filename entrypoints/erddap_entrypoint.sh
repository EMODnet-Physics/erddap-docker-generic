#!/bin/bash
set -e

# preferable to fire up Tomcat via start-tomcat.sh which will start Tomcat with
# security manager, but inheriting containers can also start Tomcat via
# catalina.sh

if [ "$1" = 'start-tomcat.sh' ] || [ "$1" = 'catalina.sh' ]; then
    ###
    # ETT Custom user
    groupadd --gid ph_HOST_ERDDAP_DATA_user_gid ph_HOST_ERDDAP_DATA_user_group && \
        useradd -u ph_HOST_ERDDAP_DATA_user_uid -g ph_HOST_ERDDAP_DATA_user_group -s /bin/bash ph_HOST_ERDDAP_DATA_user
    ###

    USER_ID=${TOMCAT_USER_ID:-1000}
    GROUP_ID=${TOMCAT_GROUP_ID:-1000}

    ###
    # Tomcat user
    ###
    groupadd -r tomcat -g ${GROUP_ID} && \
    useradd -u ${USER_ID} -g tomcat -d ${CATALINA_HOME} -s /bin/bash \
        -c "Tomcat user" tomcat
    #chfn --other='umask=0002' tomcat

    ### ETT set cors.allowed.origins
    #
    if ! grep -q 'cors.allowed.origins' ${CATALINA_HOME}/conf/web.xml; then
       sed -i 's|<filter-class>org.apache.catalina.filters.CorsFilter</filter-class>|<filter-class>org.apache.catalina.filters.CorsFilter</filter-class><init-param><param-name>cors.allowed.origins</param-name><param-value>*</param-value></init-param>|' ${CATALINA_HOME}/conf/web.xml
    fi
    sed -i 's|connectionTimeout="20000"|connectionTimeout="300000"|g' ${CATALINA_HOME}/conf/server.xml
    ###

    # ETT SSL Connector placeholder

    ###
    # Change CATALINA_HOME ownership to tomcat user and tomcat group
    # Restrict permissions on conf
    ###

    chown -R tomcat:tomcat ${CATALINA_HOME} && chmod 400 ${CATALINA_HOME}/conf/*
    sync

    ###
    # ETT Give permissions to the custom directory 'erddapData'
    chown -R tomcat:tomcat /erddapData
    # ETT Custom user
    usermod -a -G ph_HOST_ERDDAP_DATA_user_group tomcat
    ###
    
    exec gosu tomcat "$@"
fi

exec "$@"