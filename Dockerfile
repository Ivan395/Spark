FROM openjdk:11
COPY --from=python:3.9-slim / /
ENV DAEMON_RUN=true \
    SPARK_VERSION=3.1.2 \
    HADOOP_VERSION=3.2 \
    SCALA_VERSION=2.12.12 \
    SCALA_HOME=/usr/share/scala \
    SPARK_HOME=/spark \
    PYSPARK_PYTHON=python
ENV SPARK_OPTS --driver-java-options=-Xms1024M --driver-java-options=-Xmx4096M --driver-java-options=-Dlog4j.logLevel=info
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y wget tar bash coreutils procps openssl && \
    rm -rf /var/lib/apt/lists/*
RUN mkdir /tmp_scala && \
    cd /tmp_scala && \
    wget "https://downloads.typesafe.com/scala/${SCALA_VERSION}/scala-${SCALA_VERSION}.tgz" && \
    tar -xzf "scala-${SCALA_VERSION}.tgz" && \
    mkdir "${SCALA_HOME}" && \
    mv /tmp_scala/scala-${SCALA_VERSION}/* ${SCALA_HOME}/ && \
    rm -fr /tmp_scala/scala-${SCALA_VERSION}/bin/*.bat && \
    ln -s ${SCALA_HOME}/bin/* /usr/bin/ && \
    rm -rf /tmp_scala && \
    mkdir /tmp_spark && cd /tmp_spark && \
    wget "https://dlcdn.apache.org/spark/spark-${SPARK_VERSION}/spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}.tgz" && \
    tar -xzf spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}.tgz && \
    mkdir $SPARK_HOME && \
    mv spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}/* /spark/ && \
    rm -fr spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}.tgz spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION} && \
    rm -fr /tmp_spark && \
    echo "deb https://repo.scala-sbt.org/scalasbt/debian all main" | tee /etc/apt/sources.list.d/sbt.list && \
    echo "deb https://repo.scala-sbt.org/scalasbt/debian /" | tee /etc/apt/sources.list.d/sbt_old.list && \
    curl -sL "https://keyserver.ubuntu.com/pks/lookup?op=get&search=0x2EE0EA64E40A89B84B2DF73499E82A75642AC823" | apt-key add && \
    apt-get update && \
    apt-get install sbt -y && \
    rm -rf /var/lib/apt/lists/* && \
    mkdir /develop/ && \
    cd / && \
    pip install -U numpy pandas scipy matplotlib jupyter notebook pip spylon-kernel && \
    python -m spylon_kernel install
ENV PATH=$SPARK_HOME/bin:$PATH \
    PYTHONPATH=/spark/python/lib/py4j-0.10.9-src.zip:/spark/python/lib/pyspark.zip \
    SPARK_MASTER_HOST=0.0.0.0 \
    SPARK_DRIVER_HOST=0.0.0.0
EXPOSE 8888 8080 7077 4040
CMD ["jupyter", "notebook", "--allow-root", "--ip=0.0.0.0"]
