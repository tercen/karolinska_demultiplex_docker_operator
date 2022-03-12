FROM tercen/dartrusttidy:travis-17

USER root
WORKDIR /operator

RUN apt-get update && apt install -y python3-pip && python3 -m pip install Levenshtein

RUN git clone https://github.com/tercen/karolinska_demultiplex_operator.git

WORKDIR /operator/karolinska_demultiplex_operator

RUN echo "2020/03/12 - 16:05" && git pull
RUN git checkout

RUN R -e "renv::restore(confirm=FALSE)"

RUN R -e "install.packages('renv')"
RUN R -e "renv::consent(provided=TRUE);renv::restore(confirm=FALSE)"

ENTRYPOINT [ "R","--no-save","--no-restore","--no-environ","--slave","-f","main.R", "--args"]
CMD [ "--taskId", "someid", "--serviceUri", "https://tercen.com", "--token", "sometoken"]






