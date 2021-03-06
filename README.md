# FORK of Docker NFS, AWS EFS & Samba/CIFS Volume Plugin

Slight adaptation of the wonderful ContainX/docker-volume-netshare project.

- Escaping of paths in CIFS mode
- Adding retries to unmounting in CIFS mode to try to avoid accumulating loose shares due to unmounting errors
- Adding possibility to put cifs options for each machine separately in the netrc file (ex: to deal with old servers    `options ver=2.0`  )

Migration to go 1.13.9 and go mod way of managing dependencies

## How to compile

```
git clone https://github.com/nonopoubelle/docker-volume-netshare.git

cd docker-volume-netshare

docker build -t docker-volume-netshare .

docker run --rm -it -v $PWD:/go/src/github.com/nonopoubelle/docker-volume-netshare docker-volume-netshare
```


# Docker NFS, AWS EFS & Samba/CIFS Volume Plugin


Mount NFS v3/4, AWS EFS or CIFS inside your docker containers.  This is a docker plugin which enables these volume types to be directly mounted within a container.


## NFS Prerequisites on Linux

NFS needs to be installed on Linux systems in order to properly mount NFS mounts.  

- For Ubuntu/Debian: `sudo apt-get install -y nfs-common`
- For RHEL/CentOS: `sudo yum install -y nfs-utils`

It is recommend to try mounting an NFS volume to eliminate any configuration issues prior to running the plugin:
```
sudo mount -t nfs4 1.1.1.1:/mountpoint /target/mount
```

## Installation

#### From Source

```
$ go get github.com/ContainX/docker-volume-netshare
$ go build
```




## Usage

### Launching in NFS mode

**1. Run the plugin - can be added to systemd or run in the background**

```
  $ sudo docker-volume-netshare nfs
```
**2. Run the plugin - adding the correct DOCKER_API_VERSION**
If you are not using the latest stable version of docker engine please specify the version with flag.
For example:
To check docker API version:
```
docker version
Client:
Version:	17.12.0-ce
API version:	1.35
Go version:	go1.9.2
Git commit:	c97c6d6
Built:	Wed Dec 27 20:11:19 2017
OS/Arch:	linux/amd64

Server:
Engine:
 Version:	17.12.0-ce
 API version:	1.35 (minimum version 1.12)
 Go version:	go1.9.2
 Git commit:	c97c6d6
 Built:	Wed Dec 27 20:09:53 2017
 OS/Arch:	linux/amd64
 Experimental:	false
```
Here the Docker API Version is 1.35. So you should start the plugin with the right version of Docker API.

Minimum supported version for the plugin is 1.12.

```
  $ sudo docker-volume-netshare nfs -a 1.35
```


**2. Launch a container**

```
  $ docker run -i -t --volume-driver=nfs -v nfshost/path:/mount ubuntu /bin/bash
```

### Launching in EFS mode

**1. Run the plugin - can be added to systemd or run in the background**

```
  // With File System ID resolution to AZ / Region URI
  $ sudo docker-volume-netshare efs
  // For VPCs without AWS DNS - using IP for Mount
  $ sudo docker-volume-netshare efs --noresolve
```

**2. Launch a container**

```
  // Launching a container using the EFS File System ID
  $ docker run -i -t --volume-driver=efs -v fs-2324532:/mount ubuntu /bin/bash
  // Launching a container using the IP Address of the EFS mount point (--noresolve flag in plugin)
  $ docker run -i -t --volume-driver=efs -v 10.2.3.1:/mount ubuntu /bin/bash
```

### Launching in Samba/CIFS mode

#### Docker Version < 1.9.0

**1. Run the plugin - can be added to systemd or run in the background**

```
  $ sudo docker-volume-netshare cifs --username user --password pass --domain domain --security security -a docker_api_version
```

**2. Launch a container**

```
  // In CIFS the "//" is omitted and handled by netshare
  $ docker run -it --volume-driver=cifs -v cifshost/share:/mount ubuntu /bin/bash
```

##### .NetRC support

.NetRC is fully support eliminating users and passwords to be specified in step 1.  To use .netrc do the following steps:

**1. Create a /root/.netrc file (since netshare needs to be run as a root user).  Add the host and credential mappings.**  

See example:

```
  //.netrc
  machine some_hostname
       username  jeremy
       password  somepass
       domain    optional
       security  optional
       fileMode  optional
       dirMode   optional
```

**2. Run the plugin**

```
  $ sudo docker-volume-netshare cifs -a docker_api_version
```

**3. Launch a container**

```
  // In CIFS the "//" is omitted and handled by netshare
  $ docker run -it --volume-driver=cifs -v cifshost/share:/mount ubuntu /bin/bash
```

#### Docker Version 1.9.0+

Docker 1.9.0 now has support for volume management.  This allows you to user `docker volume create` to define a volume by name so
options and other info can be eliminated when running a container.

**1. Run the plugin - can be added to systemd or run in the background**

```
  $ sudo docker-volume-netshare cifs -a docker_api_version
```

**2. Create a Volume**

This will create a new volume via the Docker daemon which will call `Create` in netshare passing in the corresponding user, pass and domain info.

```
  $ docker volume create -d cifs --name cifshost/share --opt username=user --opt password=pass --opt domain=domain --opt security=security --opt fileMode=0777 --opt dirMode=0777
```

**3. Launch a container**

```
  // cifs/share matches the volume as defined in Step #2 using docker volume create
  $ docker run -it -v cifshost/share:/mount ubuntu /bin/bash
```

#### Security Option
Some CIFS servers may require a specific security mode to connect. The ``security`` option defines the ``sec`` option that is passed to ``mount.cifs``. [More information about available ``sec`` options](https://www.samba.org/~ab/output/htmldocs/manpages-3/mount.cifs.8.html).
e.g.: Apple Time Capsule's require the security mode ``ntlm``.

## License

This software is licensed under the Apache 2 license, quoted below.

Copyright 2019 ContainX / Jeremy Unruh

Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0
Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
