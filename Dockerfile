FROM apache/zeppelin:0.9.0

MAINTAINER Saagie

ENV DEBIAN_FRONTEND noninteractive

ENV JAVA_VERSION 8.131
ENV SPARK_VERSION 2.4.5
ENV HADOOP_VERSION 2.6
ENV MESOS_VERSION 1.3.1
ENV MESOS_VERSION2 2.0.1

ENV HADOOP_HOME /etc/hadoop
ENV HADOOP_CONF_DIR /etc/hadoop/conf
ENV SPARK_HOME /usr/local/spark/${SPARK_VERSION}

ENV MESOS_NATIVE_JAVA_LIBRARY /usr/lib/libmesos-${MESOS_VERSION}.so

ENV ZEPPELIN_NOTEBOOK_DIR '/notebook'
ENV ZEPPELIN_INTP_CLASSPATH_OVERRIDES /etc/hive/conf


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
RUN wget https://archive.apache.org/dist/spark/spark-${SPARK_VERSION}/spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}.tgz -P /tmp \
    && tar -zxf /tmp/spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}.tgz -C /usr/local/  \
    && cp /usr/local/spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}/conf/log4j.properties.template /usr/local/spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}/conf/log4j.properties \
    && mkdir -p /usr/local/spark \
    && mv /usr/local/spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}/ /usr/local/spark/${SPARK_VERSION} \
    && rm /tmp/spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}.tgz
########################## Install Spark END ##########################


########################## Install MESOS BEGIN ##########################
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv E56151BF && \
  DISTRO=$(lsb_release -is | tr '[:upper:]' '[:lower:]') && \
  CODENAME=$(lsb_release -cs) && \
  echo "deb http://repos.mesosphere.com/${DISTRO} ${CODENAME} main" | tee /etc/apt/sources.list.d/mesosphere.list && \
  apt-get -y update && \
  apt-get install -y --no-install-recommends \
    mesos=${MESOS_VERSION}-${MESOS_VERSION2} \
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
RUN chown -R 1000 /zeppelin && chmod 744 /zeppelin/saagie-zeppelin.sh /zeppelin/saagie-zeppelin-config.sh

# Add CRON to copy interpreter.json to persisted folder
RUN echo "* * * * * cp -f /zeppelin/conf/interpreter.json /notebook/" >> mycron && \
    crontab mycron && \
    rm mycron

RUN mkdir /notebook && chown -R 1000 /notebook

USER 1000

# Keep default ENTRYPOINT as apache/zeppelin is using Tini, which is great.
CMD ["/zeppelin/saagie-zeppelin.sh"]
