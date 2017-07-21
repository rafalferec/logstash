FROM ubuntu:trusty
  
FROM docker.elastic.co/logstash/logstash:5.5.0
RUN rm -f /usr/share/logstash/pipeline/logstash.conf
RUN rm -f /usr/share/logstash/pipeline/logstash.yml
RUN rm -f /usr/share/logstash/config/logstash.conf
RUN rm -f /usr/share/logstash/config/logstash.yml
ADD pipeline/ /usr/share/logstash/pipeline/
ADD config/ /usr/share/logstash/config/
EXPOSE 443