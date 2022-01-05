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
RUN mkdir -p /opt/geneweb/distribution
RUN chown -R geneweb:geneweb /opt/geneweb
COPY --from=builder --chown=geneweb:geneweb /home/geneweb/source/distribution /opt/geneweb/distribution

COPY --chown=geneweb:geneweb bin/gwd /opt/geneweb/distribution/
RUN chmod u+x /opt/geneweb/distribution/gwd

RUN mkdir -p /opt/geneweb/logs
RUN chown geneweb:geneweb /opt/geneweb/logs

RUN mkdir -p /opt/geneweb/bases
RUN chown geneweb:geneweb /opt/geneweb/bases

# Change user
USER geneweb

# Expose the geneweb and gwsetup ports to the docker host
EXPOSE 2317
EXPOSE 2316

# Run the container as the geneweb user
USER geneweb

ENTRYPOINT ["main.sh"]
CMD ["start-all"]
