FROM docker.elastic.co/logstash/logstash:5.5.0
RUN rm -f /usr/share/logstash/pipeline/logstash.conf
ADD pipeline/ /usr/share/logstash/pipeline/
ADD config.d/ /usr/share/logstash/config.d/