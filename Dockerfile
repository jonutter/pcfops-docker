FROM cloudfoundry/cflinuxfs3

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
  postgresql \
  ruby-dev

RUN ln -s /usr/lib/postgresql/*/bin/initdb /usr/bin/initdb && ln -s /usr/lib/postgresql/*/bin/postgres /usr/bin/postgres

RUN apt-get install -t trusty-backports shellcheck

COPY awscli-bundle.zip .
RUN unzip awscli-bundle.zip \
  && rm awscli-bundle.zip \
  && ./awscli-bundle/install -i /usr/local/aws -b /usr/local/bin/aws \
  && rm -r awscli-bundle \
  && aws --version

RUN go get github.com/onsi/ginkgo/ginkgo \
  github.com/onsi/gomega \
  gopkg.in/alecthomas/gometalinter.v2 \
  github.com/EngineerBetter/stopover \
  github.com/krishicks/yaml-patch/cmd/yaml-patch \
  github.com/EngineerBetter/yml2env

RUN mv /go/bin/gometalinter.v2 /go/bin/gometalinter

RUN gometalinter --install

RUN gem install --no-document --no-update-sources --verbose cf-uaac \
  && rm -rf /usr/lib/ruby/gems/2.5.0/cache/

COPY verify_image.sh /tmp/verify_image.sh
RUN /tmp/verify_image.sh && rm /tmp/verify_image.sh

RUN export CLOUD_SDK_REPO="cloud-sdk-$(lsb_release -c -s)"  \
  && echo "deb http://packages.cloud.google.com/apt $CLOUD_SDK_REPO main" | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list  \
  && curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -  \
  && cat /etc/apt/sources.list.d/google-cloud-sdk.list  \
  && apt-get update && apt-get install -y --no-install-recommends google-cloud-sdk
