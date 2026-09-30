# Dockerfile for an ARM64 Ubuntu 26.04
FROM --platform=linux/arm64 ubuntu@sha256:2260313b31c8c011cd2eebe728008efac1b3982be73eb71348ea2648d2c0e09b

RUN apt-get update --fix-missing
RUN apt-get install -y socat
RUN rm -rf /var/lib/apt/lists/*

RUN useradd -d /home/ctf -m -p ctf -s /bin/bash ctf

WORKDIR /home/ctf

# Copy over the binary and the flags
COPY chall /home/ctf/chall
COPY flag.txt /home/ctf/flag.txt

RUN chown -R ctf:ctf /home/ctf
RUN chmod -R 750 /home/ctf

EXPOSE 10000

# Expose the binary, resetting after timeouts
CMD su ctf -c "socat -T60 TCP-LISTEN:10000,reuseaddr,fork EXEC:/home/ctf/chall,stderr,pty,echo=0,raw,iexten=0"