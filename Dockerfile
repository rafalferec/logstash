RUN sudo add-apt-repository ppa:webupd8team/java
RUN sudo apt-get update
RUN sudo apt-get install oracle-java8-installer

RUN wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -
RUN sudo apt-get install apt-transport-https

RUN echo "deb https://artifacts.elastic.co/packages/5.x/apt stable main" | sudo tee -a /etc/apt/sources.list.d/elastic-5.x.list

RUN sudo apt-get update && sudo apt-get install logstash

CMD ["logstash", "-f /conf.d/logstash.conf"]
