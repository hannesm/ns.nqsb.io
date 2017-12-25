open Mirage

let net =
  if_impl Key.is_unix
    (socket_stackv4 [Ipaddr.V4.any])
    (static_ipv4_stack ~arp:farp default_network)

let logger = syslog_udp ~config:(syslog_config ~truncate:1484 "ns.nqsb.io") net

let dns_handler =
  let packages = [
    package "logs" ;
    package ~sublibs:["server" ; "crypto" ; "mirage"] "udns" ;
    package "nocrypto"
  ] in
  foreign
    ~deps:[abstract nocrypto; abstract logger]
    ~packages
    "Unikernel.Main"
    (random @-> pclock @-> mclock @-> time @-> stackv4 @-> job)

let () =
  register "ns.nqsb.io" [dns_handler $ default_random $ default_posix_clock $ default_monotonic_clock $ default_time $ net ]
