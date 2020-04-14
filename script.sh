#!/bin/bash
export GOPROXY=https://proxy.golang.org
#go mod init github.com/ContainX/docker-volume-netshare
go get 
go build -v
