FROM tercen/dartrusttidy:1.0.7

USER root
WORKDIR /operator

COPY demultiplex_TCR_fastqs_by_row_and_column_barcodes.py /operator/demultiplex_TCR_fastqs_by_row_and_column_barcodes.py
COPY demultiplex_TCR_fastqs_by_row_and_column_barcodes_v2.py /operator/demultiplex_TCR_fastqs_by_row_and_column_barcodes_v2.py


RUN git clone https://github.com/tercen/karolinska_demultiplex_operator.git

WORKDIR /operator/karolinska_demultiplex_operator

RUN echo "2020/02/24 - 20:24" && git pull
RUN git checkout

RUN R -e "renv::restore(confirm=FALSE)"

ENV TERCEN_SERVICE_URI https://tercen.com

COPY start.R /start.R

ENTRYPOINT [ "R","--no-save","--no-restore","--no-environ","--slave","-f","/start.R"]






