FROM docker.elastic.co/logstash/logstash:5.5.0
RUN rm -f /usr/share/logstash/pipeline/logstash.conf
ADD conf.d/ /usr/share/logstash/conf.d/
