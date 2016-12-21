## NS.NQSB.IO name server

This is a simple name server which runs on `ns.nqsb.io`.  No external data
required (no KV_RO zonefile, instead uses raw `Dns.Loader.add_*`).

Logging done via syslog.
