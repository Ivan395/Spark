FROM python:3.9-alpine
ENV DAEMON_RUN=true \
    SPARK_VERSION=3.1.2 \
    HADOOP_VERSION=3.2 \
    SCALA_VERSION=2.12.12 \
    SCALA_HOME=/usr/share/scala \
    SPARK_HOME=/spark \
    PYSPARK_PYTHON=python \
    PATH=$SPARK_HOME/bin:$PATH \
    PYTHONPATH=/spark/python/lib/py4j-0.10.9-src.zip:/spark/python/lib/pyspark.zip \
    SPARK_MASTER_HOST=0.0.0.0 \
    SPARK_DRIVER_HOST=0.0.0.0 \
    PATH=/usr/local/sbt/bin:$PATH
ENV SPARK_OPTS --driver-java-options=-Xms1024M --driver-java-options=-Xmx4096M --driver-java-options=-Dlog4j.logLevel=info
RUN apk update && \
    apk upgrade --no-cache && \
    apk add --no-cache gcc g++ make wget tar bash coreutils procps openssl gzip py3-numpy py3-matplotlib py3-pandas py3-scipy py3-argon2-cffi libffi-dev && \
    mkdir /tmp_scala && \
    cd /tmp_scala && \
    wget https://downloads.typesafe.com/scala/${SCALA_VERSION}/scala-${SCALA_VERSION}.tgz && \
    tar -xzf "scala-${SCALA_VERSION}.tgz" && \
    mkdir "${SCALA_HOME}" && \
    mv /tmp_scala/scala-${SCALA_VERSION}/* ${SCALA_HOME}/ && \
    rm -fr /tmp_scala/scala-${SCALA_VERSION}/bin/*.bat && \
    ln -s ${SCALA_HOME}/bin/* /usr/bin/ && \
    rm -rf /tmp_scala && \
    mkdir /tmp_spark && \
    wget "https://dlcdn.apache.org/spark/spark-${SPARK_VERSION}/spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}.tgz" -O /tmp_spark/spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}.tgz && \
    tar -xzf /tmp_spark/spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}.tgz -C /tmp_spark/ && \
    mkdir $SPARK_HOME && \
    mv /tmp_spark/spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}/* /spark/ && \
    rm -fr spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}.tgz spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION} && \
    rm -fr /tmp_spark && \
    mkdir /tmp_sbt /usr/local/sbt && \
    wget "https://github.com/sbt/sbt/releases/download/v1.5.5/sbt-1.5.5.tgz" -O /tmp_sbt/sbt-1.5.5.tgz && \
    tar -C /usr/local/sbt --strip-components=1 -xzf /tmp_sbt/sbt-1.5.5.tgz && \
    mkdir /develop/ && \
    cd / && \
    pip install -U  pip && \
    pip install jupyter notebook spylon-kernel && \
    python -m spylon_kernel install
EXPOSE 8888 8080 7077 4040
CMD ["jupyter", "notebook", "--allow-root", "--ip=0.0.0.0"]
