FROM golang:alpine AS builder

COPY src/app.go /opt/build/
WORKDIR /opt/build
RUN go build app.go && chmod +x ./app && ls -l /opt/build/


FROM alpine

COPY --from=builder /opt/build/app /app

ENTRYPOINT [ "" ]
CMD [ "/app" ]

