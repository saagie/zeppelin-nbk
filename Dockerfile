FROM apache/zeppelin:0.9.0

MAINTAINER Saagie

ENV DEBIAN_FRONTEND noninteractive

# Set Saagie's cluster Java version
ENV JAVA_VERSION 8.131
ENV APACHE_SPARK_VERSION 2.3.4
ENV HADOOP_VERSION 2.6

# Set Hadoop default conf dir
ENV HADOOP_HOME /etc/hadoop
ENV HADOOP_CONF_DIR /etc/hadoop/conf

# Set Spark 2.3.4 as the default one
ENV SPARK_HOME /usr/local/spark/${APACHE_SPARK_VERSION}

# Set Hive default conf dir
ENV ZEPPELIN_INTP_CLASSPATH_OVERRIDES /etc/hive/conf
# Default notebooks directory
ENV ZEPPELIN_NOTEBOOK_DIR '/notebook'


########################## LIBS PART BEGIN ##########################
USER root
# FIXME Remove once apache/zeppelin image will include PR :
# https://github.com/apache/zeppelin/pull/3755
# correcting issue :  https://issues.apache.org/jira/browse/ZEPPELIN-4783
# and once docker image will be rebuild
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 51716619E084DAB9 && \
    apt-get update -qq && apt-get install -yqq --no-install-recommends \
      jq \
      vim \
    && rm -rf /var/lib/apt/lists/*
########################## LIBS PART END ##########################


########################## Install Spark BEGIN ##########################
# Install Spark ${APACHE_SPARK_VERSION}
RUN cd /tmp && wget https://archive.apache.org/dist/spark/spark-${APACHE_SPARK_VERSION}/spark-${APACHE_SPARK_VERSION}-bin-hadoop2.6.tgz -O /tmp/spark-${APACHE_SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}.tgz
RUN cd /tmp && tar -xzf spark-${APACHE_SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}.tgz && \
  cp spark-${APACHE_SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}/conf/log4j.properties.template spark-${APACHE_SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}/conf/log4j.properties && \
  mkdir -p /usr/local/spark/${APACHE_SPARK_VERSION} && mv spark-${APACHE_SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}/* /usr/local/spark/${APACHE_SPARK_VERSION} && \
  rm -rf spark-${APACHE_SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}.tgz spark-${APACHE_SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}
########################## Install Spark END ##########################


########################## Install MESOS BEGIN ##########################
# Install Mesos ${MESOS_VERSION}
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv E56151BF && \
  DISTRO=$(lsb_release -is | tr '[:upper:]' '[:lower:]') && \
  CODENAME=$(lsb_release -cs) && \
  echo "deb http://repos.mesosphere.com/${DISTRO} ${CODENAME} main" | tee /etc/apt/sources.list.d/mesosphere.list && \
  apt-get -y update && \
  apt-get install -y --no-install-recommends mesos=${MESOS_VERSION}-${MESOS_VERSION2} \
  && rm -rf /var/lib/apt/lists/*
########################## Install MESOS END ##########################


########################## Install Kerberos Client BEGIN ##########################
RUN apt update -qq && apt install -yqq --no-install-recommends \
      krb5-user && \
    rm -rf /var/lib/apt/lists/*;
########################## Install Kerberos Client END ##########################


# Add a startup script that will setup Spark conf before running Zeppelin
ADD saagie-zeppelin.sh /zeppelin
ADD saagie-zeppelin-config.sh /zeppelin
RUN chmod 744 /zeppelin/saagie-zeppelin.sh /zeppelin/saagie-zeppelin-config.sh

RUN mkdir ${ZEPPELIN_NOTEBOOK_DIR} && chown -R 1000 ${ZEPPELIN_NOTEBOOK_DIR}

USER 1000

# Add CRON to copy interpreter.json to persisted folder
RUN echo "* * * * * cp -f /zeppelin/conf/interpreter.json ${ZEPPELIN_NOTEBOOK_DIR}/" >> mycron && \
crontab mycron && \
rm mycron

# Keep default ENTRYPOINT as apache/zeppelin is using Tini, which is great.
CMD ["/zeppelin/saagie-zeppelin.sh"]
