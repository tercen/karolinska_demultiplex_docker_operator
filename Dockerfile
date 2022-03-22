FROM tercen/runtime-r40:4.0.4-1

ENV RENV_VERSION 0.13.0
RUN R -e "install.packages('remotes', repos = c(CRAN = 'https://cran.r-project.org'))"
RUN R -e "remotes::install_github('rstudio/renv@${RENV_VERSION}')"

RUN echo 'options("tercen.serviceUri"="http://tercen:5400/api/v1/")' >> /usr/local/lib/R/etc/Rprofile.site && \
    echo 'options("tercen.username"="admin")' >> /usr/local/lib/R/etc/Rprofile.site && \
    echo 'options("tercen.password"="admin")' >> /usr/local/lib/R/etc/Rprofile.site && \
    echo 'options(renv.consent = TRUE)' >> /usr/local/lib/R/etc/Rprofile.site && \
    echo 'options(repos=c(TERCEN="https://cran.tercen.com/api/v1/rlib/tercen",\
     CRAN="https://cran.tercen.com/api/v1/rlib/CRAN", \
     BioCsoft="https://cran.tercen.com/api/v1/rlib/BioCsoft-3.12", \
     BioCann="https://cran.tercen.com/api/v1/rlib/BioCann-3.12", \
     BioCexp="https://cran.tercen.com/api/v1/rlib/BioCexp-3.12", \
     BioCworkflows="https://cran.tercen.com/api/v1/rlib/BioCworkflows-3.12" \
     ))' >> /usr/local/lib/R/etc/Rprofile.site

RUN python3 -m pip install Levenshtein

RUN echo "2022/03/12 22:29"
COPY . /operator
WORKDIR /operator

#RUN R -e "renv::init(bare = TRUE)"
#RUN R -e "renv::install('askpass')"
#RUN R -e "renv::hydrate()"

RUN R -e "renv::consent(provided=TRUE);renv::restore(confirm=FALSE)"

ENTRYPOINT [ "R","--no-save","--no-restore","--no-environ","--slave","-f","main.R", "--args"]
CMD [ "--taskId", "someid", "--serviceUri", "https://tercen.com", "--token", "sometoken"]

