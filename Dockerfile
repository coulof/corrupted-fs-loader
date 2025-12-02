FROM alpine:latest

# Install required utilities for loading/block operations
RUN apk add --no-cache e2fsprogs util-linux coreutils curl

RUN curl -LO https://github.com/tytso/e2fsprogs/archive/refs/heads/master.zip && unzip master.zip && \
    find /e2fsprogs-master -type f ! -name 'image.gz' -exec rm -f {} + && \
    find /e2fsprogs-master -type d -empty -delete && \
    find /e2fsprogs-master -type f -name 'image.gz' -exec gunzip {} +

RUN dd if=/dev/zero of=/test.img bs=1M count=10 && mkfs.ext3 /test.img

# Copy the entrypoint script
COPY entrypoint.sh /entrypoint.sh
# Make the script executable
RUN chmod +x /entrypoint.sh

# Set the entrypoint to the loading script
ENTRYPOINT ["/entrypoint.sh"]
