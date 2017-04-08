open Mirage

let net =
  if_impl Key.is_unix
    (socket_stackv4 [Ipaddr.V4.any])
    (static_ipv4_stack ~arp:farp default_network)

let logger = syslog_udp net

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
