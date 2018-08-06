FROM cloudfoundry/cflinuxfs2

ENV GOPATH /go
ENV PATH $GOPATH/bin:/usr/local/go/bin:$PATH

COPY terraform /usr/bin/terraform
COPY cf /usr/bin/cf
COPY jq /usr/bin/jq
COPY om /usr/bin/om
COPY fly /usr/bin/fly
COPY bosh /usr/bin/bosh
COPY bbl /usr/bin/bbl
COPY yaml /usr/bin/yaml
COPY yaml /usr/bin/yq
COPY credhub /usr/bin/credhub
COPY certstrap /usr/bin/certstrap
COPY install_binaries.sh .
RUN ./install_binaries.sh

COPY go.tar.gz .
RUN tar -C /usr/local -xzf go.tar.gz \
    && rm go.tar.gz \
    && mkdir -p "$GOPATH/src" "$GOPATH/bin" && chmod -R 777 "$GOPATH"

RUN echo "deb http://archive.ubuntu.com/ubuntu trusty-backports main restricted universe multiverse" \
    >> /etc/apt/sources.list

RUN apt-get update && apt-get install -y --no-install-recommends \
    python-dev \
    parallel \
    software-properties-common

RUN apt-get install -t trusty-backports shellcheck

COPY awscli-bundle.zip .
RUN unzip awscli-bundle.zip \
    && rm awscli-bundle.zip \
    && ./awscli-bundle/install -i /usr/local/aws -b /usr/local/bin/aws \
    && rm -r awscli-bundle \
    && aws --version

RUN go get github.com/onsi/ginkgo/ginkgo \
    github.com/onsi/gomega \
    github.com/alecthomas/gometalinter.v2 \
    github.com/EngineerBetter/stopover \
    github.com/krishicks/yaml-patch/cmd/yaml-patch \
    github.com/EngineerBetter/yml2env

RUN gem install --no-document --no-update-sources --verbose cf-uaac \
    && rm -rf /usr/lib/ruby/gems/2.3.0/cache/
