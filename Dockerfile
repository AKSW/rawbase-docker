FROM ubuntu:12.04

RUN apt-get update && \
  apt-get install unzip wget git libssl-dev autoconf \
  automake libtool flex bison gperf maven \
  gawk m4 make libncurses5-dev openjdk-7-jdk -y && \
  update-alternatives --set java /usr/lib/jvm/java-7-openjdk-amd64/jre/bin/java && \
  rm -rf /var/lib/apt/lists/*

RUN cd /tmp && \
  wget https://github.com/openlink/virtuoso-opensource/archive/v6.1.7.zip -O virtuoso-opensource.zip && \
  unzip -q virtuoso-opensource.zip && \
  mkdir virtuoso-opensource && \
  mv virtuoso-opensource-6.1.7 virtuoso-opensource/6.1.7 && \
  cd virtuoso-opensource/6.1.7 && \
  ./autogen.sh && \
  ./configure --program-transform-name="s/isql/isql-v/" --disable-all-vads && \
  make && \
  make install && \
  cd /usr/bin && \
  ln -s /usr/local/virtuoso-opensource/bin/isql-v isql-vt && \
  rm -rf /tmp/virtuoso-opensource.zip /tmp/virtuoso-opensource

ENV RAWBASE_HOME=/var/docker/rawbase-server
ENV VIRTUOSO=/usr/local/virtuoso-opensource/bin/virtuoso-t
ENV VIRTUOSO_CFG=/usr/local/virtuoso-opensource/var/lib/virtuoso/db/virtuoso.ini

RUN git clone https://github.com/rawbase/rawbase-server.git $RAWBASE_HOME
ADD install.sh $RAWBASE_HOME/install/install.sh
RUN $VIRTUOSO -c $VIRTUOSO_CFG && \
  sleep 15s && \
  cd $RAWBASE_HOME && \
  install/install.sh
ADD config.js $RAWBASE_HOME/pages/rawbase/js/app/config.js

WORKDIR /var/docker
ADD run.sh run.sh
RUN chmod +x run.sh

EXPOSE 80 8890 1111

CMD /var/docker/run.sh
