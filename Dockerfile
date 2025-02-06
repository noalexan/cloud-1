FROM alpine:latest

RUN apk add --update --no-cache ansible openssh

WORKDIR /cloud-1

CMD [ "ansible-playbook", "-i", "inventory.yml", "playbook.yml" ]
