FROM scratch
# copy the rootfs into the image
COPY rootfs/filesystem/ /
# default to /bin/sh if no command is specified
CMD ["/bin/sh"]