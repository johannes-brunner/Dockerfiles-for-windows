# Build a asp.net 4.5 container based on iis
# use 
# docker build -t iisaspnet .
# to build this image

FROM microsoft/iis

MAINTAINER johannes.brunner@world-direct.at

RUN powershell -Command \
    import-module servermanager; \
    add-windowsfeature Web-Net-Ext45,Web-Asp-Net45, NET-Framework-45-ASPNET