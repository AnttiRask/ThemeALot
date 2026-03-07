FROM rocker/r-ver:4.4.2

# Install system dependencies needed by R packages
RUN apt-get update && apt-get install -y --no-install-recommends \
    libssl-dev \
    libcurl4-openssl-dev \
    libxml2-dev \
    libfontconfig1-dev \
    libharfbuzz-dev \
    libfribidi-dev \
    libfreetype6-dev \
    libpng-dev \
    libtiff5-dev \
    libjpeg-dev \
    && rm -rf /var/lib/apt/lists/*

# Install Microsoft and common fonts for Power BI theme preview
RUN echo "ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true" | debconf-set-selections \
    && apt-get update && apt-get install -y --no-install-recommends \
    fontconfig \
    fonts-liberation \
    fonts-dejavu-core \
    fonts-freefont-ttf \
    ttf-mscorefonts-installer \
    fonts-crosextra-carlito \
    fonts-crosextra-caladea \
    cabextract \
    && rm -rf /var/lib/apt/lists/* \
    && fc-cache -fv

# Install R packages
RUN Rscript -e "install.packages(c( \
    'shiny', \
    'bslib', \
    'bsicons', \
    'plotly', \
    'reactable', \
    'jsonlite', \
    'dplyr', \
    'lubridate', \
    'colourpicker', \
    'shinyjs', \
    'colorspace', \
    'col2hex2col' \
  ), repos = 'https://cloud.r-project.org', quiet = TRUE)"

# Copy the app
COPY . /app

WORKDIR /app

# Cloud Run passes the port via $PORT (default 8080)
EXPOSE 8080

CMD ["Rscript", "-e", \
  "shiny::runApp('/app', host='0.0.0.0', port=as.integer(Sys.getenv('PORT', unset='8080')))"]
