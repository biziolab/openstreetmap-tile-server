FROM overv/openstreetmap-tile-server:latest

COPY ./singapore.osm.pbf /data.osm.pbf

ENV USER renderer
ENV USER_ID 10000

RUN usermod -u $USER_ID $USER
RUN groupmod -g $USER_ID $USER

COPY run.sh /
RUN ./run.sh import

COPY apache.conf /etc/apache2/sites-available/000-default.conf
COPY ports.conf /etc/apache2/ports.conf

# Fix permissions
RUN echo "export APACHE_RUN_USER=renderer \n \
  export APACHE_RUN_GROUP=renderer" >> /etc/apache2/envvars

RUN mkdir /var/run/apache2 \
  && chown -R $USER:$USER /var/run/apache2 \
  && chown -R $USER:$USER /etc/apache2 \
  && chown -R $USER:$USER /var/lib/apache2 \
  && chown -R $USER:$USER /var/log/postgresql \
  && chmod 0700 /var/log/postgresql \
  && chown -R $USER:$USER /var/log \
  && chown -R $USER:$USER /var/run/postgresql \
  && chown -R $USER:$USER /etc/postgresql/12 \
  && chown -R $USER:$USER /var/lib/postgresql \
  && chown -R $USER:$USER /etc/ssl/private \
  && chmod 0600 /etc/ssl/private/ssl-cert-snakeoil.key \
  && chown -R $USER:$USER /usr/local/etc \
  && chown -R $USER:$USER /var/run/renderd \
  && chown -R $USER:$USER /var/lib/mod_tile

USER $USER

EXPOSE 8080

ENTRYPOINT ["/run.sh"]
CMD []
