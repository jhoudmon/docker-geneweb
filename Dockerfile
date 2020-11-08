FROM alpine:3.12.1 AS builder

# Install packages
RUN apk add build-base ocaml opam coreutils git m4 perl gmp-dev
 
# Create geneweb user
RUN adduser --disabled-password geneweb

# Change user
USER geneweb

# Copy files
RUN mkdir -p /home/geneweb
COPY --chown=geneweb:geneweb geneweb_install.sh /home/geneweb

# Make script executable
RUN chmod a+x /home/geneweb/geneweb_install.sh

# Install geneweb
RUN /home/geneweb/geneweb_install.sh

# Create final container with compiled binaries
FROM alpine:3.12.1

# Install packages
RUN apk add bash gmp

# Copy script to local bin folder
COPY bin/*.sh /usr/local/bin/

# Make script executable
RUN chmod a+x /usr/local/bin/*.sh

# Create geneweb user
RUN adduser --disabled-password geneweb

# Copy files
RUN mkdir -p /home/geneweb/distribution
RUN mkdir -p /home/geneweb/logs
COPY --from=builder --chown=geneweb:geneweb /home/geneweb/source/distribution /home/geneweb/distribution

# Change user
USER geneweb

# Default language to be English
ENV LANGUAGE en

# Default access to gwsetup is from docker host
ENV HOST_IP 172.17.0.1

# Change the geneweb home directory to our database path to avoid stomping on debian package path /var/lib/geneweb
RUN mkdir -p /home/geneweb/data

# Create a volume on the container
VOLUME /home/geneweb/data

# Expose the geneweb and gwsetup ports to the docker host
EXPOSE 2317
EXPOSE 2316

# Run the container as the geneweb user
USER geneweb

ENTRYPOINT ["main.sh"]
CMD ["start-all"]
