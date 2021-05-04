FROM overv/openstreetmap-tile-server:latest

COPY ./singapore.osm.pbf /data.osm.pbf

ENV MY_USER renderer

# RUN addgroup --gid 10000 $MY_USER

# RUN adduser --home /home/renderer --system --uid 10000 --gid 10000 $MY_USER

RUN usermod -u 10000 $MY_USER
RUN groupmod -g 10000 $MY_USER

COPY run.sh /
RUN ./run.sh import

COPY apache.conf /etc/apache2/sites-available/000-default.conf
COPY ports.conf /etc/apache2/ports.conf

RUN echo 'renderer ALL=NOPASSWD: /usr/sbin/service postgresql start' >> /etc/sudoers

RUN echo "export APACHE_RUN_USER=renderer \n \
  export APACHE_RUN_GROUP=renderer" >> /etc/apache2/envvars

RUN cat /etc/apache2/envvars

RUN chown -R $MY_USER:$MY_USER /var/log/postgresql \
  && chmod 0700 /var/log/postgresql

RUN mkdir /var/run/apache2
RUN chown -R $MY_USER:$MY_USER /var/run/apache2

RUN chown -R $MY_USER:$MY_USER /var/log \
  && chown -R $MY_USER:$MY_USER /etc/apache2 \
  && chown -R $MY_USER:$MY_USER /var/lib/apache2 \
  && chown -R $MY_USER:$MY_USER /var/run/postgresql \
  && chown -R $MY_USER:$MY_USER /etc/postgresql/12 \
  && chown -R $MY_USER:$MY_USER /var/lib/postgresql \
  && chown -R $MY_USER:$MY_USER /etc/ssl/private \
  && chmod 0600 /etc/ssl/private/ssl-cert-snakeoil.key \
  && chown -R $MY_USER:$MY_USER /usr/local/etc \
  && chown -R $MY_USER:$MY_USER /var/run/renderd \
  && chown -R $MY_USER:$MY_USER /var/lib/mod_tile

RUN sudo service apache2 stop

USER $MY_USER

# RUN ./run.sh run

ENTRYPOINT ["/run.sh"]
CMD []

EXPOSE 8080
