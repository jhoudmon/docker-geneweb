FROM alpine:3.15.0 AS builder

# Install packages
RUN apk add build-base ocaml opam coreutils git m4 perl gmp-dev bash perl-utils

RUN cpan IPC::System::Simple
RUN cpan String::ShellQuote
 
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
FROM alpine:3.15.0 

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
COPY --from=builder --chown=geneweb:geneweb /home/geneweb/source/distribution /home/geneweb/distribution

RUN mkdir -p /home/geneweb/logs
RUN chown geneweb:geneweb /home/geneweb/logs

# Change user
USER geneweb

# Default language to be English
ENV LANGUAGE en

# Default access to gwsetup is from docker host
ENV HOST_IP 172.17.0.1

# Expose the geneweb and gwsetup ports to the docker host
EXPOSE 2317
EXPOSE 2316

# Run the container as the geneweb user
USER geneweb

ENTRYPOINT ["main.sh"]
CMD ["start-all"]
