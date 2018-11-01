open Mirage

let net =
  if_impl Key.is_unix
    (socket_stackv4 [Ipaddr.V4.any])
    (static_ipv4_stack ~arp:farp default_network)

let logger = syslog_udp ~config:(syslog_config ~truncate:1484 "ns.nqsb.io") net

let keys =
  let doc = Key.Arg.info ~doc:"nsupdate keys (name:type:value,...)" ["keys"] in
  Key.(create "keys" Arg.(opt (list string) [] doc))

let dns_handler =
  let packages = [
    package "logs" ;
    package ~sublibs:["server" ; "crypto" ; "mirage.server"] "udns" ;
    package "nocrypto"
  ]
  and keys = Key.([ abstract keys ])
  in
  foreign
    ~deps:[ abstract nocrypto ; abstract logger ; abstract app_info ]
    ~keys
    ~packages
    "Unikernel.Main"
    (random @-> pclock @-> mclock @-> time @-> stackv4 @-> job)

let () =
  register "nsnqsb" [dns_handler $ default_random $ default_posix_clock $ default_monotonic_clock $ default_time $ net ]
