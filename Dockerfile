FROM alpine:latest

# Install required utilities for loading/block operations
RUN apk add --no-cache e2fsprogs util-linux coreutils curl

RUN curl -LO https://github.com/tytso/e2fsprogs/raw/refs/heads/master/tests/f_baddir/image.gz && \
    gunzip image.gz &&  mv image /image_f_baddir.img

# Copy the entrypoint script
COPY entrypoint.sh /entrypoint.sh
# Make the script executable
RUN chmod +x /entrypoint.sh

# Set the entrypoint to the loading script
ENTRYPOINT ["/entrypoint.sh"]