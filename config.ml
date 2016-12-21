open Mirage

let address =
  let network = Ipaddr.V4.Prefix.of_address_string_exn "198.167.222.200/24"
  and gateway = Ipaddr.V4.of_string "198.167.222.1"
  in
  { network ; gateway }

let net =
  if_impl Key.is_unix
    (socket_stackv4 [Ipaddr.V4.any])
    (static_ipv4_stack ~config:address default_network)

let dns_handler =
  let packages = [
    package ~sublibs:["mirage"] "dns";
    package ~sublibs:["mirage"] "logs-syslog";
    package ~sublibs:["lwt"] "logs"
  ] in
  foreign
    ~packages
    "Unikernel.Main" (console @-> pclock @-> stackv4 @-> job)

let () =
  register "dns" [dns_handler $ default_console $ default_posix_clock $ net]
