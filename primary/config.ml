open Mirage

let net = generic_stackv4 default_network

let logger = syslog_udp ~config:(syslog_config "ns.nqsb.io") net

let keys =
  let doc = Key.Arg.info ~doc:"nsupdate keys (name:type:value,...)" ["keys"] in
  Key.(create "keys" Arg.(opt (list string) [] doc))

let dns_handler =
  let packages = [
    package "logs" ;
    package ~min:"0.2.1" "logs-syslog" ;
    package ~sublibs:["server" ; "crypto" ; "mirage.server"] "udns" ;
    package "nocrypto" ;
    package ~min:"3.7.1" "tcpip" ;
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
