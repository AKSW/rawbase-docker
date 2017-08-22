FROM ubuntu:12.04

RUN apt-get update && \
  apt-get install unzip wget git libssl-dev autoconf \
  automake libtool flex bison gperf maven \
  gawk m4 make libncurses5-dev openjdk-7-jdk -y && \
  update-alternatives --set java /usr/lib/jvm/java-7-openjdk-amd64/jre/bin/java

RUN wget https://github.com/openlink/virtuoso-opensource/archive/v6.1.7.zip -O virtuoso-opensource.zip && \
  unzip -q virtuoso-opensource.zip && \
  mkdir virtuoso-opensource && \
  mv virtuoso-opensource-6.1.7 virtuoso-opensource/6.1.7

WORKDIR virtuoso-opensource/6.1.7

RUN ./autogen.sh && \
  ./configure --program-transform-name="s/isql/isql-v/" --disable-all-vads && \
  make && \
  make install

EXPOSE 1111 8890 80

WORKDIR /var/docker
ADD run.sh run.sh
RUN chmod +x run.sh

RUN cd /usr/bin && ln -s /usr/local/virtuoso-opensource/bin/isql-v isql-vt

RUN git clone https://github.com/rawbase/rawbase-server.git /var/docker/rawbase-server
ADD install.sh /var/docker/rawbase-server/install/install.sh
RUN /usr/local/virtuoso-opensource/bin/virtuoso-t -c /usr/local/virtuoso-opensource/var/lib/virtuoso/db/virtuoso.ini && \
  sleep 15s && \
  cd /var/docker/rawbase-server && \
  RAWBASE_HOME=/var/docker/rawbase-server install/install.sh

CMD /usr/local/virtuoso-opensource/bin/virtuoso-t -c /usr/local/virtuoso-opensource/var/lib/virtuoso/db/virtuoso.ini && \
  sleep 3s && \
  rawbase-server/rawbase-server.sh 80
