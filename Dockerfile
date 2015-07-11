FROM ubuntu:14.04
MAINTAINER Tiago Rolim <tiago.rol@gmail.com>

#Non interactive
ENV DEBIAN_FRONTEND noninteractive
RUN echo "mysql-server mysql-server/root_password password mysql_pass" | debconf-set-selections
RUN echo "mysql-server mysql-server/root_password_again password mysql_pass" | debconf-set-selections

#Atualizando o Linux
RUN sudo apt-get update && \
    sudo apt-get -y upgrade

#Instalando o mysql
RUN sudo apt-get -y install mysql-server

#Permissão para acesso remoto
RUN sudo sed -i "s/\(bind-address[\t ]*\)=.*/\1= 0.0.0.0/" /etc/mysql/my.cnf

#Restart
RUN sudo service mysql restart && \
    sudo mysql -uroot -pmysql_pass -e "CREATE DATABASE wordpress;" && \
    sudo mysql -uroot -pmysql_pass -e "CREATE USER 'wordpressuser'@'%';" && \
    sudo mysql -uroot -pmysql_pass -e "SET PASSWORD FOR 'wordpressuser'@'%'= PASSWORD('mysql_pass');" && \
    sudo mysql -uroot -pmysql_pass -e "GRANT ALL PRIVILEGES ON wordpress.* TO 'wordpressuser'@'%'; FLUSH PRIVILEGES;"

#Permissão
ADD run.sh /usr/local/bin/run.sh
RUN chmod +x /usr/local/bin/run.sh

EXPOSE 3306

VOLUME ["/var/lib/mysql"]

CMD ["/usr/local/bin/run.sh"]
