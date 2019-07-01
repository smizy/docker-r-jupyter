FROM alpine:3.8

ARG BUILD_DATE
ARG VCS_REF
ARG VERSION

LABEL \
    maintainer="smizy" \
    org.label-schema.build-date=$BUILD_DATE \
    org.label-schema.docker.dockerfile="/Dockerfile" \
    org.label-schema.license="Apache License 2.0" \
    org.label-schema.name="smizy/r-jupyter" \
    org.label-schema.url="https://github.com/smizy" \
    org.label-schema.vcs-ref=$VCS_REF \
    org.label-schema.vcs-type="Git" \
    org.label-schema.version=$VERSION \
    org.label-schema.vcs-url="https://github.com/smizy/docker-r-jupyter"

ENV  R_PROFILE  /etc/R/Rprofile.site

RUN set -x \
    && apk update \
    && apk --no-cache add \
        bash \
        freetype \
        gsl \
        libxml2 \
        python3 \
        py3-tornado \
        R \
        su-exec \ 
        tini \
        zeromq \
    && apk --no-cache add --virtual .builddeps \
        build-base \
        freetype-dev \
        gsl-dev \
        libressl-dev \
        libxml2-dev \
        openblas-dev \
        perl \
        python3-dev \
        R-dev \
        zeromq-dev \
    && pip3 install --upgrade pip \
    && pip3 install jupyter \
    ## jp font
    && wget https://oscdl.ipa.go.jp/IPAexfont/ipaexg00401.zip \
    && unzip ipaexg00401.zip \
    && mkdir -p /usr/share/fonts \
    && mv ipaexg00401/ipaexg.ttf /usr/share/fonts/ \
    && echo 'options(repos = c(CRAN = "https://cloud.r-project.org/"))' >> /etc/R/Rprofile.site \
    ## R jupyter kernel
    && Rscript -e "install.packages(c('crayon', 'pbdZMQ'))" \
    # - Workaround: fs install error
    && Rscript -e "install.packages('https://github.com/r-lib/devtools/archive/v1.13.6.tar.gz', repos=NULL, type='soruce')" \
    && Rscript -e "devtools::install_github(paste0('IRkernel/', c('repr', 'IRdisplay', 'IRkernel')))" \
    && Rscript -e "IRkernel::installspec(user = FALSE)" \
    # -
    && Rscript -e 'install.packages("tidyverse")' \
    && Rscript -e 'install.packages("tidytext")' \
    ## user/owner
    && adduser -D  -g '' -s /sbin/nologin -u 1000 docker \
    && adduser -D  -g '' -s /sbin/nologin jupyter \
    && addgroup jupyter docker  \
    && chown -R jupyter:jupyter /home/jupyter \
    ## dir
    && mkdir -p /etc/jupyter \
    ## clean
    && find /usr/lib/python3.6 -name __pycache__ | xargs rm -r \
    && rm -rf \
        /root/.[acpw]* \
        ipaexg00401* \
    && apk del .builddeps

USER jupyter

WORKDIR /code

COPY entrypoint.sh  /usr/local/bin/
COPY jupyter_notebook_config.py /etc/jupyter/

EXPOSE 8888

ENTRYPOINT ["/sbin/tini", "--", "entrypoint.sh"]
CMD ["jupyter", "notebook"]