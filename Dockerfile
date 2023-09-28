FROM takusuman/copadocker:latest

RUN mkdir -p /usr/local/bin /var/rinha
RUN ln /bin/ksh /bin/ksh93
COPY herbiec.ksh ./usr/local/bin

CMD jq -M . /var/rinha/source.rinha.json | ksh /usr/local/bin/herbiec.ksh
