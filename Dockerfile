FROM kbase/depl:latest
MAINTAINER KBase Developer
# Install the SDK (should go away eventually)
RUN \
  . /kb/dev_container/user-env.sh && \
  cd /kb/dev_container/modules && \
  rm -rf jars && \
  git clone https://github.com/kbase/jars && \
  rm -rf kb_sdk && \
  git clone https://github.com/kbase/kb_sdk -b develop && \
  cd /kb/dev_container/modules/jars && \
  make && make deploy && \
  cd /kb/dev_container/modules/kb_sdk && \
  make && make deploy

# -----------------------------------------

# Insert apt-get instructions here to install
# any required dependencies for your module.

# -----------------------------------------

COPY ./ /kb/module
ENV PATH=$PATH:/kb/dev_container/modules/kb_sdk/bin

WORKDIR /kb/module

RUN make
RUN make deploy
RUN mkdir -p /kb/module/work

ENTRYPOINT [ "./scripts/entrypoint.sh" ]

CMD [ ]
