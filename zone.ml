open Dns

let n = Name.of_string_list ["nqsb"; "io"]

let sn p = Name.of_string_list [ p ; "nqsb" ; "io" ]
let ns = sn "ns"
let ns' = sn "sn"

let ns2 = Name.of_string_list ["ns";"mehnert"; "org"]
let mx = Name.of_string_list ["mail";"mehnert"; "org"]

let serial = 201704080l
and refresh = 16384l
and retry = 2048l
and expire = 1048576l
and min = 2560l
and ttl = 259200l

let ip = Ipaddr.V4.of_string_exn

let db =
  let db = Loader.new_db () in
  Loader.add_soa_rr ns (sn "hostmaster") serial refresh retry expire min ttl n db;
  Loader.add_ns_rr ns ttl n db;
  Loader.add_ns_rr ns' ttl n db;
  Loader.add_ns_rr ns2 ttl n db;
  Loader.add_a_rr (ip "198.167.222.200") ttl ns db;
  Loader.add_a_rr (ip "194.150.168.146") ttl ns' db;
  Loader.add_mx_rr 10 mx ttl n db;
  Loader.add_a_rr (ip "198.167.222.201") ttl n db;
  Loader.add_a_rr (ip "198.167.222.201") ttl (sn "usenix15") db;
  Loader.add_a_rr (ip "198.167.222.201") ttl (sn "tron") db;
  Loader.add_a_rr (ip "198.167.222.205") ttl (sn "hannes") db;
  Loader.add_a_rr (ip "198.167.222.207") ttl (sn "shell") db;
  Loader.add_a_rr (ip "198.167.222.209") ttl (sn "kinda") db;
  Loader.add_a_rr (ip "198.167.222.210") ttl (sn "tls") db;
  db
