---
title: zabbix添加网络设备
key: zabbix
tag: zabbix
sidebar:
  nav: zabbix
---

zabbix添加各品牌网络设备进行管理和拓扑图建立策略。

<!--more-->

### 华为交换机

交换机上面配置命令

````shell
snmp-agent
snmp-agent community read zabbix@123
snmp-agent sys-info version all
snmp-agent target-host trap address udp-domain X.X.X.X udp-port 161 params securityname zabbix@123 v2c
snmp-agent trap enable
````
