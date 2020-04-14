FROM golang:1.13.9

## dkv-netshare is BASE image used by CIFS, NFS tafs
##
RUN mkdir /build
RUN mkdir -p /go/src/github.com/nonopoubelle/docker-volume-netshare
WORKDIR /go/src/github.com/nonopoubelle/docker-volume-netshare
CMD ./script.sh
