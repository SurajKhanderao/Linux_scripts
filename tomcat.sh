#!/bin/bash

# Install Latest Java (Amazon Corretto 21)
dnf install java-21-amazon-corretto-devel -y

# Download and extract Tomcat
cd /tmp
wget https://archive.apache.org/dist/tomcat/tomcat-10/v10.1.34/bin/apache-tomcat-10.1.34.tar.gz
mkdir -p /opt/tomcat
tar -xzf apache-tomcat-10.1.34.tar.gz -C /opt/tomcat --strip-components=1

# Create user and set permissions
useradd -r -m -d /opt/tomcat -s /bin/false tomcat
chown -R tomcat:tomcat /opt/tomcat

# Configure single user (tomcat/tomcat123)
cat > /opt/tomcat/conf/tomcat-users.xml << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<tomcat-users>
    <role rolename="manager-gui"/>
    <role rolename="manager-script"/>
    <user username="tomcat" password="tomcat123" roles="manager-gui,manager-script"/>
</tomcat-users>
EOF

# Fix context files
cat > /opt/tomcat/webapps/manager/META-INF/context.xml << 'EOF'
<Context antiResourceLocking="false" privileged="true" >
</Context>
EOF

#<< coment
#cat > /opt/tomcat/webapps/host-manager/META-INF/context.xml << 'EOF'
#<Context antiResourceLocking="false" privileged="true" >
#</Context>
#EOF
#coment

# Start Tomcat
chmod +x /opt/tomcat/bin/*.sh
/opt/tomcat/bin/startup.sh



<< coment
Tomcat Manager URL: http://YOUR_IP:8080/manager/html

Username: tomcat
Password: tomcat123

Jenkins Integration:
Username: tomcat
Password: tomcat123

coment
#!/bin/bash

# Install Latest Java (Amazon Corretto 21)
dnf install java-21-amazon-corretto-devel -y

# Download and extract Tomcat
cd /tmp
wget https://archive.apache.org/dist/tomcat/tomcat-10/v10.1.34/bin/apache-tomcat-10.1.34.tar.gz
mkdir -p /opt/tomcat
tar -xzf apache-tomcat-10.1.34.tar.gz -C /opt/tomcat --strip-components=1

# Create user and set permissions
useradd -r -m -d /opt/tomcat -s /bin/false tomcat
chown -R tomcat:tomcat /opt/tomcat

# Configure single user (tomcat/tomcat123)
cat > /opt/tomcat/conf/tomcat-users.xml << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<tomcat-users>
    <role rolename="manager-gui"/>
    <role rolename="manager-script"/>
    <user username="tomcat" password="tomcat123" roles="manager-gui,manager-script"/>
</tomcat-users>
EOF

# Fix context files
cat > /opt/tomcat/webapps/manager/META-INF/context.xml << 'EOF'
<Context antiResourceLocking="false" privileged="true" >
</Context>
EOF

cat > /opt/tomcat/webapps/host-manager/META-INF/context.xml << 'EOF'
<Context antiResourceLocking="false" privileged="true" >
</Context>
EOF

# Start Tomcat
chmod +x /opt/tomcat/bin/*.sh
/opt/tomcat/bin/startup.sh



<< coment
Tomcat Manager URL: http://YOUR_IP:8080/manager/html

Username: tomcat
Password: tomcat123

Jenkins Integration:
Username: tomcat
Password: tomcat123

coment
