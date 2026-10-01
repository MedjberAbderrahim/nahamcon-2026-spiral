# Dockerfile for an ARM64 Ubuntu 26.04
FROM ubuntu@sha256:2260313b31c8c011cd2eebe728008efac1b3982be73eb71348ea2648d2c0e09b

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

# Change to the ctf user directly in Dockerfile
USER ctf

EXPOSE 10000

# Use Exec form (JSON array) so socat runs as PID 1
CMD ["socat", "-T60", "TCP-LISTEN:10000,reuseaddr,fork", "EXEC:/home/ctf/chall,stderr,pty,echo=0,raw,iexten=0"]