FROM google/cloud-sdk:alpine

RUN apk add bash
COPY install.sh /install.sh
RUN chmod +x /install.sh
COPY cloud-init.yml /installer/cloud-init.yml

WORKDIR /installer
ENTRYPOINT [ "bash" ]
CMD [ "/install.sh" ]