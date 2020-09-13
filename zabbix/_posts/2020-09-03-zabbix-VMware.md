---
title: zabbix添加VMware
key: zabbix
tag: zabbix
sidebar:
  nav: zabbix
---

zabbix添加VCenter和Esxi监控虚拟机运行状态和性能。

<!--more-->

## zabbix监控VMware所需要用到的VMware组件

下面截取官方的说明

````bash
StartVMwareCollectors - the number of pre-forked vmware collector instances.
This value depends on the number of VMware services you are going to monitor. For the most cases this should be:

servicenum < StartVMwareCollectors < (servicenum * 2)

where servicenum is the number of VMware services. E. g. if you have 1 VMware service to monitor set StartVMwareCollectors to 2, if you have 3 VMware services, set it to 5. Note that in most cases this value should not be less than 2 and should not be 2 times greater than the number of VMware services that you monitor. Also keep in mind that this value also depends on your VMware environment size and VMwareFrequency and VMwarePerfFrequency configuration parameters (see below).

VMwareCacheSize

VMwareFrequency

VMwarePerfFrequency

VMwareTimeout
````

具体需要配置如下4个参数

- StartVMwareCollectors
- VMwareCacheSize
- VMwareFrequency
- VMwarePerfFrequency
- VMwareTimeout
