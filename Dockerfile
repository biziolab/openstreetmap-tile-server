FROM overv/openstreetmap-tile-server:v2.1.0

COPY singapore.osm.pbf /data/region.osm.pbf

ENV ALLOW_CORS enabled
ENV USER renderer
ENV USER_ID 10000

RUN usermod -u $USER_ID $USER
RUN groupmod -g $USER_ID $USER

RUN mkdir -p /tmp/efs/fs1

COPY run.sh /
RUN ./run.sh import

COPY apache.conf /etc/apache2/sites-available/000-default.conf
COPY ports.conf /etc/apache2/ports.conf
COPY renderd.conf /usr/local/etc/renderd.conf

COPY ./static/leaflet.html /var/www/html/index.html
COPY ./static/leaflet.css /var/www/html/leaflet.css
COPY ./static/leaflet.js /var/www/html/leaflet.js

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
  && chown -R $USER:$USER /etc/postgresql/14 \
  && chown -R $USER:$USER /var/lib/postgresql \
  && chown -R $USER:$USER /etc/ssl/private \
  && chmod 0600 /etc/ssl/private/ssl-cert-snakeoil.key \
  && chown -R $USER:$USER /usr/local/etc \
  && chown -R $USER:$USER /var/run/renderd \
  && chown -R $USER:$USER /var/lib/mod_tile \
  && chown -R $USER:$USER /var/www/html \
  && chown -R $USER:$USER /tmp \
  && chown -R $USER:$USER /data/database/ \
  && chown -R $USER:$USER /data/database/postgres/

USER $USER

EXPOSE 8080

ENTRYPOINT ["/run.sh"]
CMD ["run"]
