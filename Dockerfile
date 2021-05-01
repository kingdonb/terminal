FROM okteto/cloudbin:1.8.39 as flux

ADD https://github.com/fluxcd/flux2/releases/download/v0.13.2/flux_0.13.2_linux_amd64.tar.gz flux.tgz
RUN tar zxvf flux.tgz && mv flux /usr/local/bin/flux

FROM alpine:3 as build

RUN apk add go git
RUN mkdir -p /tmp/gotty 
RUN GOPATH=/tmp/gotty go get github.com/yudai/gotty 
ENV GOPATH /tmp/kubectx
RUN go get -d github.com/ahmetb/kubectx || true
WORKDIR $GOPATH/src/github.com/ahmetb/kubectx
RUN go build ./cmd/... && go install  ./cmd/...
RUN mv /tmp/gotty/bin/gotty /usr/local/bin/ 
RUN mv /tmp/kubectx/bin/kubectx /usr/local/bin/ 
RUN mv /tmp/kubectx/bin/kubens /usr/local/bin/ 

FROM alpine:3

RUN apk add --no-cache bash curl iputils \
  git vim git-perl git-email fzf gcc g++ build-base
COPY bashrc /root/.bashrc
COPY bash_aliases /root/.bash_aliases

COPY --from=build /usr/local/bin/gotty /usr/local/bin/gotty
COPY --from=build /usr/local/bin/kubectx /usr/local/bin/kubectx
COPY --from=build /usr/local/bin/kubens /usr/local/bin/kubens
COPY --from=flux /usr/local/bin/kubectl /usr/local/bin/kubectl
COPY --from=flux /usr/local/bin/okteto /usr/local/bin/okteto
COPY --from=flux /usr/local/bin/helm /usr/local/bin/helm
COPY --from=flux /usr/local/bin/flux /usr/local/bin/flux

ENV HOME /root
EXPOSE 8080
CMD ["sh", "-c", "/usr/local/bin/gotty --permit-write --reconnect /bin/bash"]
