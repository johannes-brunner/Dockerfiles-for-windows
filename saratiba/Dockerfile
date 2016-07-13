# Create the saratiba application in docker
# use
# docker build -t saratiba .
# to build the image.

FROM iisaspnet

MAINTAINER johannes.brunner@world-direct.at

#RUN xy leads to cmd /S /C xy
#this is a nice info if someone wants to test the commands in the shell

#BUG TP4 backslash must be escaped in env var. 
#If you have a look at the issue tracker there are lots of variations that do not work too with env var.
#BUG TP4 = does not work too. 
ENV sqlserver DOCKERHOSTWD.cloudapp.net
ENV port 1433

CMD powershell ./start detached

#BUG TP4 Expose is not supported
#EXPOSE 80

# make install files accessible in the container
COPY . /install

WORKDIR /install


#BUG Tried to install urlrewrite per chocolatey but somehow after a while it does not work
# anymore, because of bugs in the urlwrite chocolatey module.
# Don't know how this is tested but seems it is no good idea to use chocolatey in the long term.
#RUN powershell -Command \    
#    iex ((new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1'))
#    choco install -y urlrewrite --force
# Therefore forced to use the installer directly
RUN /install/rewrite.msi /quiet /l* urlrewrite.log

#enable application interfaces on port 8899 and 8085
# BUG NT AUTHORITY\NETWORK SERVICE works only on english OS. On german OS this is another name.
# BUG this command seems not to work if chained with ;\ Sorry.
RUN netsh http add urlacl url=http://+:8899/ user="NT AUTHORITY\NETWORK SERVICE"
RUN netsh http add urlacl url=http://+:8085/ user="NT AUTHORITY\NETWORK SERVICE"
    
#The installer of saratiba must be copied to the install directory before building this image.
RUN /install/Installer.msi /quiet /l* install.log

#BUG DO not use double quites in this powershell commands, this does not work here
# Adapt lot of configurations and build the correct environment.
RUN powershell -Command \
    $secpasswd = ConvertTo-SecureString 'password' -AsPlainText -Force; \
    $mycreds = New-Object System.Management.Automation.PSCredential ('NT AUTHORITY\NETWORK SERVICE', $secpasswd); \
    New-Service -name 'Saratiba' -binaryPathName 'C:\Saratiba\Application\OnCode.Application.exe' -Description 'Saratiba' -displayName 'Saratiba' -startupType Manual -credential $mycreds; \
    $connectionString='Server=%sqlserver%,%port%;Database=Saratiba;User Id=sa;Password=thepassword2#;MultipleActiveResultSets=true;'; \
    $connectionStringAuth='Server=%sqlserver%,%port%;Database=Saratiba.Auth;User Id=sa;Password=thepassword2#;MultipleActiveResultSets=true;'; \
    $xml = New-Object XML; \
    $xml.Load('C:\Saratiba\Configuration\Operations.config'); \
    $xml.configuration.connectionStrings.add[0].connectionString = $connectionString; \
    $xml.configuration.connectionStrings.add[1].SetAttribute('providerName', 'System.Data.SqlClient'); \
    $xml.configuration.connectionStrings.add[1].connectionString = $connectionStringAuth; \
    $xml.Save('C:\Saratiba\Configuration\Operations.config'); \
    $xml = New-Object XML; \
    $xml.Load('C:\Saratiba\Configuration\AppSettings.config'); \
    $xml.configuration.appSettings.add[9].value = 'loopback://localhost/saratiba_default_queue'; \
    $xml.configuration.appSettings.add[10].value = 'false'; \
    $xml.Save('C:\Saratiba\Configuration\AppSettings.config'); \
    $xml = New-Object XML; \
    $xml.Load('C:\Saratiba\ASP Frontend\Web.config'); \
    $xml.configuration.'system.webserver'.staticContent.RemoveAll(); \
    $xml.Save('C:\Saratiba\ASP Frontend\Web.config'); \
    import-module webadministration; \
    Stop-Website -Name 'Default Web Site'; \
    Remove-Website -Name 'Default Web Site'; \
    IIS: ;\
    new-website -Name Saratiba -PhysicalPath 'C:\Saratiba\ASP Frontend\' -Port 80 -ApplicationPool 'DefaultAppPool'