FROM ubuntu:16.04
LABEL maintainer="Vinicius Raupp <vinicius.alves@canoas.ifrs.edu.br>"
ENV DEBIAN_FRONTEND=noninteractive
ENV VPLJAIL_INSTALL_DIR /etc/vpl
ENV FQDN vpl.canoas.ifrs.edu.br

RUN apt-get -q update && apt-get -yq install --no-install-recommends vim curl apt-utils autotools-dev automake  \
	openssl libssl-dev gconf2 firefox \
	make g++ gcc gdb nodejs php7.0-cli php7.0-sqlite python pydb python-tk \
	 locales supervisor && rm -rf /var/lib/apt/lists/* \
	&& localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8

ENV LANG en_US.utf8
ENV LANGUAGE en_US.UTF-8
ENV LC_ALL en_US.UTF-8

RUN curl http://vpl.dis.ulpgc.es/releases/vpl-jail-system-2.2.2.tar.gz | tar -zxC /tmp/
COPY supervisor-vpl.conf /etc/supervisor/conf.d/

WORKDIR /tmp/vpl-jail-system-2.2.2/

RUN ./configure && make
RUN mkdir $VPLJAIL_INSTALL_DIR && cp src/vpl-jail-server $VPLJAIL_INSTALL_DIR && cp -i vpl-jail-system.conf $VPLJAIL_INSTALL_DIR \
	&& chmod 600 $VPLJAIL_INSTALL_DIR/vpl-jail-system.conf && cp vpl_*.sh /etc/vpl && chmod +x /etc/vpl/*.sh \
	&& cp vpl-jail-system.initd /etc/init.d/vpl-jail-system && chmod +x /etc/init.d/vpl-jail-system \
	&& mkdir /var/vpl-jail-system && chmod 0600 /var/vpl-jail-system

COPY docker-build-sh .
RUN ./docker-build-sh
WORKDIR /etc/vpl/
CMD ["/usr/bin/supervisord", "-n", "-c", "/etc/supervisor/supervisord.conf"]


