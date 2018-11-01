## nqsb.io name server unikernels

The MirageOS unikernel serving DNS as `ns.nqsb.io` is developed in the `primary`
subfolder.

The secondary - aka `sn.nqsb.io` - is in the `secondary` subfolder. This waits
for DNS notify frames from `sn.nqsb.io` and does periodically `SOA` requests
and `AXFR` zone transfers.

Key material is provided via command line parameters.

Logging done via syslog.
