# 介绍

在`alpine`容器里面开启`ssh`，以便宿主机可以直接通过`vscode`的`ssh remote`插件登陆进去容器进行开发。

## 快速开始

### 配置变量

你需要修改`docker-compose.yml`文件里面的变量。

#### CODEDIR_VOLUME（建议配置）

指的是你宿主机的代码希望挂在到容器的哪个位置。例如：

```shell
CODEDIR_VOLUME=~/codeDir:/root/codeDir
```

#### HTTP_PROXY（按需配置，非必须）

指的是为容器里面配置HTTP代理。例如：`http://127.0.0.1:8080`。

> 如果不需要代理，可以删除此环境变量

#### HTTPS_PROXY（按需配置，非必须）

指的是为容器里面配置HTTPS代理。例如：`http://127.0.0.1:8080`。

> 如果不需要代理，可以删除此环境变量

#### HOST_SSH_PORT（必须）

指的是容器为宿主机暴露出来的ssh端口。例如：`9522`。

#### PASSWORD（必须）

指的是容器中root用户的密码，用来登陆容器用的。例如：`123456`。

### 编译镜像

```shell
docker-compose build
```

### 启动容器

```shell
docker-compose up -d
```

### 登陆容器

```shell
ssh root@127.0.0.1 -p 9522
root@127.0.0.1's password:
```

登陆成功之后，将会进入容器：

```shell
Welcome to Alpine!

The Alpine Wiki contains a large amount of how-to guides and general
information about administrating Alpine systems.
See <http://wiki.alpinelinux.org/>.

You can setup the system with the command: setup-alpine

You may change this message by editing /etc/motd.

4e4cc9a72177:~#
```
