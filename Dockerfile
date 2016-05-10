FROM centos:latest 
USER root 
 
# Set the WILDFLY_VERSION env variable 
ENV WILDFLY_VERSION 10.0.0.Final 
ENV JBOSS_HOME /wildfly 

 
# Add the WildFly distribution to /opt, and make wildfly the owner of the extracted tar content 
# Make sure the distribution is available from a well-known place 
 

RUN cd $HOME && \ 
    yum install tar java jdk zip unzip wget curl -y && \ 
    wget "http://downloads.jboss.org/apiman/1.2.5.Final/apiman-distro-wildfly10-1.2.5.Final-overlay.zip" && \ 
    mv apiman-distro-wildfly10-1.2.5.Final-overlay.zip apiman-distro-overlay.zip && \ 
    unzip -o apiman-distro-overlay.zip -d $JBOSS_HOME && \ 
    wget http://www.java2s.com/Code/JarDownload/ojdbc6/ojdbc6.jar.zip && \ 
    unzip ojdbc6.jar.zip && \ 
    mv ojdbc6.jar $JBOSS_HOME/standalone/deployments && \ 
    rm -f $JBOSS_HOME/standalone/deployments/apiman-es.war 
    cd $HOME 
ADD postgresql-9.4.1208.jar $JBOSS_HOME/standalone/deployments 
ADD standalone-apiman.xml $JBOSS_HOME/standalone/configuration 
ADD apiman.properties $JBOSS_HOME/standalone/configuration 
RUN RUN $JBOSS_HOME/bin/add-user.sh admin P@ssw0rd10 --silent 
# Ensure signals are forwarded to the JVM process correctly for graceful shutdown 
ENV LAUNCH_JBOSS_IN_BACKGROUND true 


# Expose the ports we're interested in 
EXPOSE 8080 9990 8443 

 
#: For systemd usage this changes to /usr/sbin/init 
# Keeping it as /bin/bash for compatability with previous 
CMD ["/wildfly/bin/standalone.sh", -c "standalone-apiman.xml"] 
