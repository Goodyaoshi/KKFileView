FROM keking/kkfileview-jdk:4.1.1
MAINTAINER chenjh "842761733@qq.com"
ADD server/target/kkFileView-*.tar.gz /opt/
ENV KKFILEVIEW_BIN_FOLDER /opt/kkFileView-4.2.0/bin
ENTRYPOINT ["java","-Dfile.encoding=UTF-8","-Dspring.config.location=/opt/kkFileView-4.2.0/config/application.properties","-jar","/opt/kkFileView-4.2.0/bin/kkFileView-4.2.0.jar","->","/opt/kkFileView-4.2.0/log/kkFileView.log"]
