FROM alpine

ENV options="" cron="*/30 * * * *"

RUN apk update \
    && apk add --no-cache git curl jq bash \
    && git clone https://gitlab.com/finzzz/cf_dynamic_ip.git \
    && apk del git 

ENTRYPOINT  sh -c "echo '$cron /cf_dynamic_ip/run.sh $options' > /etc/crontabs/root && crond -f"
