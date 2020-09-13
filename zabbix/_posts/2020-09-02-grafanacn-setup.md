---
title: grafana汉化版本装
key: zabbix
tag: zabbix
sidebar:
  nav: zabbix
---

计划用zabbix容器方式进行标准化部署，记录具体操作步骤和遇到的问题。

<!--more-->

## 环境准备

### 修改源

### docker环境准备

使用官方安装脚本自动安装

````bash
curl -fsSL https://get.docker.com | bash -s docker --mirror Aliyun
````

启动daemon服务（否则无法pull镜像）

systemctl daemon-reload
systemctl restart docker.service

## 安装zabbix服务器（官方subnet）

### 分配subnet网络

````bash
docker network create --subnet 172.20.0.0/16 --ip-range 172.20.240.0/20 zabbix-net
````

### 安装mysql服务

推送mysql容器镜像

````bash
docker pull mysql:8.0
````

````bash
docker run --name mysql-server -t \
      -e MYSQL_DATABASE="zabbix" \
      -e MYSQL_USER="zabbix" \
      -e MYSQL_PASSWORD="zabbix" \
      -e MYSQL_ROOT_PASSWORD="zabbix" \
      --network=zabbix-net \
      -d mysql:8.0\
      --character-set-server=utf8 --collation-server=utf8_bin \
      --default-authentication-plugin=mysql_native_password
````

````bash
docker pull zabbix/zabbix-java-gateway:alpine-5.0-latest
````

````bash
docker run --name zabbix-java-gateway -t \
      --network=zabbix-net \
      --restart unless-stopped \
      -d zabbix/zabbix-java-gateway:alpine-5.0-latest
````

````bash
docker pull zabbix/zabbix-server-mysql:alpine-5.0-latest
````

````bash
docker run --name zabbix-server-mysql -t \
      -e DB_SERVER_HOST="mysql-server" \
      -e MYSQL_DATABASE="zabbix" \
      -e MYSQL_USER="zabbix" \
      -e MYSQL_PASSWORD="zabbix" \
      -e MYSQL_ROOT_PASSWORD="zabbix" \
      -e ZBX_JAVAGATEWAY="zabbix-java-gateway" \
      --network=zabbix-net \
      -p 10051:10051 \
      --restart unless-stopped \
      -d zabbix/zabbix-server-mysql:alpine-5.0-latest
````

````bash
docker pull zabbix/zabbix-web-nginx-mysql:alpine-5.0-latest
````

````bash
docker run --name zabbix-web-nginx-mysql -t \
      -e ZBX_SERVER_HOST="zabbix-server-mysql" \
      -e DB_SERVER_HOST="mysql-server" \
      -e MYSQL_DATABASE="zabbix" \
      -e MYSQL_USER="zabbix" \
      -e MYSQL_PASSWORD="zabbix" \
      -e MYSQL_ROOT_PASSWORD="zabbix" \
      -e PHP_TZ="Asia/Shanghai" \
      --network=zabbix-net \
      -p 80:8080 \
      --restart unless-stopped \
      -d zabbix/zabbix-web-nginx-mysql:alpine-5.0-latest
````

### docker容器安装agent

````bash
docker pull zabbix/zabbix-agent:latest
````

````bash
docker run --name zabbix-agent-mysql -t \
      -e ZBX_SERVER_HOST="zabbix-server-mysql" \
      -e DB_SERVER_HOST="mysql-server" \
      -e MYSQL_DATABASE="zabbix" \
      -e MYSQL_USER="zabbix" \
      -e MYSQL_PASSWORD="zabbix" \
      -e MYSQL_ROOT_PASSWORD="zabbix" \
      --network=zabbix-net \
      --restart unless-stopped \
      -d zabbix/zabbix-agent:latest
````

### 宿主机安装agent

服务器添加agent服务

添加zabbix源

````bash
rpm --import http://repo.zabbix.com/RPM-GPG-KEY-ZABBIX
rpm -ihv http://repo.zabbix.com/zabbix/3.0/rhel/7/x86_64/zabbix-release-3.0-1.el7.noarch.rpm
````

查找zabbix-agent安装包

````shell
[root@localhost ~]# yum list |grep zabbix
http://repo.zabbix.com/zabbix/3.0/rhel/7/x86_64/repodata/87818fcd36f485539b03954419261114f2aabed465e8405db3830d40bea080b4-primary.sqlite.bz2: [Errno 14] curl#18 - "transfer closed with 50216 bytes remaining to read"
Trying other mirror.
zabbix-release.noarch                       3.0-1.el7                  installed
fping.x86_64                                3.10-1.el7                 zabbix-non-supported
iksemel.x86_64                              1.4-2.el7.centos           zabbix-non-supported
iksemel-devel.x86_64                        1.4-2.el7.centos           zabbix-non-supported
iksemel-utils.x86_64                        1.4-2.el7.centos           zabbix-non-supported
pcp-export-pcp2zabbix.x86_64                4.3.2-7.el7_8              updates
pcp-export-zabbix-agent.x86_64              4.3.2-7.el7_8              updates
zabbix-agent.x86_64                         3.0.31-1.el7               zabbix
zabbix-get.x86_64                           3.0.31-1.el7               zabbix
zabbix-java-gateway.x86_64                  3.0.31-1.el7               zabbix
zabbix-proxy-mysql.x86_64                   3.0.31-1.el7               zabbix
zabbix-proxy-pgsql.x86_64                   3.0.31-1.el7               zabbix
zabbix-proxy-sqlite3.x86_64                 3.0.31-1.el7               zabbix
zabbix-sender.x86_64                        3.0.31-1.el7               zabbix
zabbix-server-mysql.x86_64                  3.0.31-1.el7               zabbix
zabbix-server-pgsql.x86_64                  3.0.31-1.el7               zabbix
zabbix-web.noarch                           3.0.31-1.el7               zabbix
zabbix-web-japanese.noarch                  3.0.31-1.el7               zabbix
zabbix-web-mysql.noarch                     3.0.31-1.el7               zabbix
zabbix-web-pgsql.noarch                     3.0.31-1.el7               zabbix
````

安装zabbix-agent

yum -y install zabbix-agent.x86_64

修改配置文件

docker inspect [OPTIONS] NAME|ID [NAME|ID...] 查看nginx容器的IP地址

vi /etc/zabbix/zabbix_agentd.conf 修改server地址为容器的IP地址

这里有个坑就是容器访问到服务器外面的时候使用的并非容器自身地址，agent会报错添加报错的IP即可，报错如下
{:.error}

````shell
27623:20200902:075514.013 active check configuration update from [172.20.240.4:10051] started to fail (cannot connect to [[172.20.240.4]:10051]: [111] Connection refused)
27622:20200902:075846.076 failed to accept an incoming connection: connection from "172.20.240.3" rejected, allowed hosts: "172.20.240.4"
````

systemctl enable zabbix-agent.service      开机自启动

systemctl start zabbix-agent.service          启动服务

放通10050端口

````bash
firewall-cmd --zone=public --add-port=10050/tcp --permanent
````

````bash
systemctl restart firewalld.service
````

或者 （业务中断时间短，服务不会重启）

````bash
firewall-cmd --reload
````

添加center本机的对外IP地址为监控zabbix服务器

### 修改容器的时区

````bash
docker 06ef6e824023 update PHP_TZ="Asia/Shanghai"
````

### 中文图形小方框修正

上传宋体字体到容器内

````bash
docker cp simsun.ttf a67221334256:/usr/share/zabbix/assets/fonts/simsun.ttf ##拷贝字体
docker exec -it a67221334256 /bin/bash ##进入容器
vi /usr/share/zabbix/include/defines.inc.php ##修改配置文件
````

````shell
define('ZBX_GRAPH_FONT_NAME',           'simsun'); // font file name
define('ZBX_GRAPH_LEGEND_HEIGHT',       120); // when graph height is less then this value, some legend will not show up
````

这里有个坑是win10复制过来的宋体ttc文件上面去完全不显示文字，试了几个其他的ttf中文字体也是，建议去网上下载宋体ttf格式的文件，测试正常。
{:.error}

## 安装zabbix服务器（bridge方式——失败）

````bash
docker run --name mysql-server -t \
      -e MYSQL_DATABASE="zabbix" \
      -e MYSQL_USER="zabbix" \
      -e MYSQL_PASSWORD="zabbix" \
      -e MYSQL_ROOT_PASSWORD="zabbix" \
      --network=bridge \
      -d mysql:8.0\
      --character-set-server=utf8 --collation-server=utf8_bin \
      --default-authentication-plugin=mysql_native_password
````

````bash
docker run --name zabbix-java-gateway -t \
      --network=bridge \
      --restart unless-stopped \
      -d zabbix/zabbix-java-gateway:alpine-5.0-latest
````

````bash
docker run --name zabbix-server-mysql -t \
      -e DB_SERVER_HOST="mysql-server" \
      -e MYSQL_DATABASE="zabbix" \
      -e MYSQL_USER="zabbix" \
      -e MYSQL_PASSWORD="zabbix" \
      -e MYSQL_ROOT_PASSWORD="zabbix" \
      -e ZBX_JAVAGATEWAY="zabbix-java-gateway" \
      --network=bridge \
      -p 10051:10051 \
      --restart unless-stopped \
      -d zabbix/zabbix-server-mysql:alpine-5.0-latest
````

````bash
docker run --name zabbix-web-nginx-mysql -t \
      -e ZBX_SERVER_HOST="zabbix-server-mysql" \
      -e DB_SERVER_HOST="mysql-server" \
      -e MYSQL_DATABASE="zabbix" \
      -e MYSQL_USER="zabbix" \
      -e MYSQL_PASSWORD="zabbix" \
      -e MYSQL_ROOT_PASSWORD="zabbix" \
      --network=bridge \
      -p 80:8080 \
      --restart unless-stopped \
      -d zabbix/zabbix-web-nginx-mysql:alpine-5.0-latest
````

````bash
docker run --name zabbix-agent-mysql -t \
      -e ZBX_SERVER_HOST="zabbix-server-mysql" \
      -e DB_SERVER_HOST="mysql-server" \
      -e MYSQL_DATABASE="zabbix" \
      -e MYSQL_USER="zabbix" \
      -e MYSQL_PASSWORD="zabbix" \
      -e MYSQL_ROOT_PASSWORD="zabbix" \
      --network=bridge \
      --restart unless-stopped \
      -d zabbix/zabbix-agent:latest
````
### 容器问题

vmware collector 无法启动
