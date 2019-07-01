# docker-R

R with Jupyter docker image based on alpine

tidyverse packages, including ggplot2, dplyr, tidyr, readr, purrr, tibble, stringr, lubridate, and broom, etc. libs pre-installed. See detail in installed.packages() results.

## Usage

```
# run Jupyter Notebook container (see token in log)
docker run -it --rm -p 8888:8888 -v $PWD:/code smizy/r-notebook:3.5.0-alpine

# Or use PASSWORD environment variable instead of token
docker run  -p 8888:8888 -v $PWD:/code -e PASSWORD=yoursecretpass -d smizy/r-notebook:3.5.0-alpine

# open browser
open http://$(docker-machine ip default):8888
```

## Install more packages

In case of "tm"

```Dockerfile
FROM smizy/r-notebook:3.5.0-alpine 

USER root

RUN set -x \
    && apk --no-cache add \
        libxml2 \
    && apk --no-cache add --virtual .builddeps \
        build-base \
        libxml2-dev \
        R-dev \
    && R -e 'install.packages("tm")' \
    && apk del .builddeps

USER jupyter
```

