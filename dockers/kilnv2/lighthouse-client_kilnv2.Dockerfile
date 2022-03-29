FROM geth:merge-kiln-v2 as geth_builder
FROM besu:main as besu_builder
FROM nethermind:kiln as nethermind_builder
FROM lighthouse:unstable as lighthouse_builder

FROM base-consensus:latest 

ARG USER=lighthouse
ARG UID=10002

# See https://stackoverflow.com/a/55757473/12429735RUN
RUN adduser \
    --disabled-password \
    --gecos "" \
    --home "/home/lighthouse/" \
    --shell "/usr/sbin/nologin" \
    --uid "${UID}" \
    "${USER}"

# in case we run "safe" examples.
RUN mkdir -p /var/lib/lighthouse/beacon && chown ${USER}:${USER} /var/lib/lighthouse/beacon && chmod 700 /var/lib/lighthouse/beacon
RUN mkdir -p /var/lib/lighthouse/validators && chown ${USER}:${USER} /var/lib/lighthouse/validators && chmod 700 /var/lib/lighthouse/validators

# Copy executable
COPY --from=lighthouse_builder /usr/local/bin/lighthouse /usr/local/bin/lighthouse

# Setup execution clients.
# add geth stuff
COPY --from=geth_builder /usr/local/bin/geth /usr/local/bin/geth
RUN mkdir -p /var/lib/goethereum && chown ${USER}:${USER} /var/lib/goethereum
# add besu 
COPY --from=besu_builder /opt/besu/. /opt/besu
RUN mkdir -p /var/lib/besu && chown -R ${USER}:${USER} /var/lib/besu && chmod -R 700 /var/lib/besu
RUN ln -s /opt/besu/bin/besu /usr/local/bin/besu
# add nethermind 
RUN mkdir /nethermind
COPY --from=nethermind_builder  /nethermind/. .
RUN chown -R ${USER}:${USER} /nethermind
RUN mkdir -p /var/lib/nethermind && chown ${USER}:${USER} /var/lib/nethermind
RUN ln -s  /nethermind/Nethermind.Runner /usr/local/bin/nethermind

WORKDIR /home/lighthouse

# where all of the ethereum-testnet-bootstrapper volumes get mounted in. 
RUN mkdir -p /data && mkdir -p /source && chown -R ${USER}:${USER} /data && chown -R ${USER}:${USER} /source

ENTRYPOINT ["/bin/bash"]
