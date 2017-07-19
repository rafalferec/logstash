FROM nginx
FROM openjdk:8-jre
ADD ./nginx.conf /etc/nginx/conf.d/default
ADD /src /www
FROM docker.elastic.co/logstash/logstash:5.5.0

