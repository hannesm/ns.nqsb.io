open Mirage

let address =
  let network = Ipaddr.V4.Prefix.of_address_string_exn "194.150.168.146/28"
  and gateway = Ipaddr.V4.of_string "194.150.168.145"
  in
  { network ; gateway }

let net =
  if_impl Key.is_unix
    (socket_stackv4 [Ipaddr.V4.any])
    (static_ipv4_stack ~config:address ~arp:farp default_network)

let logger =
  syslog_udp
    (syslog_config ~truncate:1484 "sn.nqsb.io" (Ipaddr.V4.of_string_exn "194.150.168.145"))
    net

let dns_handler =
  let packages = [
    package ~min:"0.20.0" ~sublibs:["mirage"] "dns";
    package ~sublibs:["lwt"] "logs"
  ] in
  foreign
    ~deps:[abstract logger]
    ~packages
    "Unikernel.Main" (stackv4 @-> job)

let () =
  register "dns" [dns_handler $ net]
