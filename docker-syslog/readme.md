# Docker 基于 centos7 搭建 syslog-ng 服务端。

> https://www.syslog-ng.com/community/b/blog/posts/writing-python-destination-in-syslog-ng-how-to-send-log-messages-to-mqtt

## 客户端和服务端配置 
- 正好file倒过来就是了。
```
@version: 3.22
@include "scl.conf"

source source_1 { network(
        ip("0.0.0.0")
        port(30052)
        flags(syslog-protocol)
        transport("tcp")
    ); };

destination dst_1 { file("/opt/log/access.log"); };

log { source(source_1); destination(dst_1); };
```

## 使用镜像后，python拓展说明
```Dockerfile 
from <image>

ADD requirements.txt /requirements.txt
RUN pip install -r /requirements.txt

```