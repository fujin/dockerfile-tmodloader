FROM mono:slim

# Update and install needed utils
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y curl nuget vim zip && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# fix for favorites.json error
RUN favorites_path="/root/My Games/Terraria" && mkdir -p "$favorites_path" && echo "{}" > "$favorites_path/favorites.json"

RUN mkdir /tmp/terraria && \
    cd /tmp/terraria && \
    curl -sL https://github.com/tModLoader/tModLoader/releases/download/v0.11.7.5/tModLoader.Linux.v0.11.7.5.zip --output terraria-server.zip && \
    unzip -q terraria-server.zip && \
    curl -sL https://raw.githubusercontent.com/tModLoader/tModLoader/master/solutions/ReleaseExtras/WindowsFiles/serverconfig.txt --output serverconfig-default.txt && \
    mkdir /tmodloader && \
    mv * /tmodloader/ && \
    rm -R /tmp/* && \
    chmod +x /tmodloader/tModLoaderServer* && \
    if [ ! -f /tmodloader/tModLoaderServer ]; then echo "Missing /tmodloader/tModLoaderServer"; exit 1; fi

COPY run-vanilla.sh /tmodloader/run.sh

# Commit Hash Metadata
ARG VCS_REF
LABEL org.label-schema.vcs-ref=$VCS_REF \
    org.label-schema.vcs-url="https://github.com/fujin/dockerfile-tmodloader"

# Allow for external data
VOLUME ["/config"]

# Run the server
WORKDIR /tmodloader
ENTRYPOINT ["./run.sh"]
