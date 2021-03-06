(* (c) 2017, 2018 Hannes Mehnert, all rights reserved *)

open Mirage

let net = generic_stackv4 default_network

let logger = syslog_udp ~config:(syslog_config ~truncate:1484 "snnqsb") net

let keys =
  let doc = Key.Arg.info ~doc:"nsupdate keys (name:type:value,...)" ["keys"] in
  Key.(create "keys" Arg.(opt (list string) [] doc))

let dns_handler =
  let packages = [
    package "logs" ;
    package ~sublibs:[ "server" ; "mirage.server" ; "crypto" ] "udns" ;
    package "nocrypto"
  ]
  and keys = Key.([ abstract keys ])
  in
  foreign
    ~deps:[abstract nocrypto ; abstract logger]
    ~keys
    ~packages
    "Unikernel.Main" (random @-> pclock @-> mclock @-> time @-> stackv4 @-> job)

let () =
  register "snnqsb" [dns_handler $ default_random $ default_posix_clock $ default_monotonic_clock $ default_time $ net ]
