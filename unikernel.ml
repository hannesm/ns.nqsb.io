open Mirage_types_lwt

module Main (R : RANDOM) (P : PCLOCK) (M : MCLOCK) (T : TIME) (S : STACKV4) = struct

  module D = Dns_mirage.Make(R)(P)(M)(T)(S)

  let data =
    let zone = Dns_name.of_string_exn "nqsb.io" in
    let n = Dns_name.prepend_exn zone
    and ip = Ipaddr.V4.of_string_exn
    and ss = Dns_name.DomSet.of_list
    in
    let ns = n "ns"
    and ttl = 2560l
    and ns' = n "sn"
    and mx = Dns_name.of_string_exn "mail.mehnert.org"
    in
    let soa = Dns_packet.({ nameserver = ns ;
                            hostmaster = n "hostmaster" ;
                            serial = 2l ; refresh = 16384l ; retry = 2048l ;
                            expiry = 1048576l ; minimum = ttl })
    in
    let open Dns_trie in
    let open Dns_map in
    let t = insert zone (V (K.Soa, (ttl, soa))) Dns_trie.empty in
    let t = insert zone (V (K.Ns, (ttl, ss [ ns ; ns' ]))) t in
    let t = insert ns (V (K.A, (ttl, [ ip "198.167.222.200" ]))) t in
    let t = insert ns' (V (K.A, (ttl, [ ip "194.150.168.146" ]))) t in
    let t = insert zone (V (K.A, (ttl, [ ip "198.167.222.201" ]))) t in
    let t = insert zone (V (K.Mx, (ttl, [ (10, mx) ]))) t in
    let t = insert (n "usenix15") (V (K.A, (ttl, [ ip "198.167.222.201" ]))) t in
    let t = insert (n "tron") (V (K.A, (ttl, [ ip "198.167.222.201" ]))) t in
    let t = insert (n "hannes") (V (K.A, (ttl, [ ip "198.167.222.205" ]))) t in
    let t = insert (n "shell") (V (K.A, (ttl, [ ip "198.167.222.207" ]))) t in
    let t = insert (n "kinda") (V (K.A, (ttl, [ ip "198.167.222.209" ]))) t in
    let t = insert (n "tls") (V (K.A, (ttl, [ ip "198.167.222.210" ]))) t in
    let t = insert (n "netsem") (V (K.A, (ttl, [ ip "198.167.222.213" ]))) t in
    let t = insert (n "contao") (V (K.A, (ttl, [ ip "198.167.222.212" ]))) t in
    t

  let start _rng pclock mclock _ s _ _ info =
    Logs.info (fun m -> m "used packages: %a"
                  Fmt.(Dump.list @@ pair ~sep:(unit ".") string string)
                  info.Mirage_info.packages) ;
    Logs.info (fun m -> m "used libraries: %a"
                  Fmt.(Dump.list string) info.Mirage_info.libraries) ;
    let trie = data in
    (match Dns_trie.check trie with
     | Ok () -> ()
     | Error e ->
       Logs.err (fun m -> m "error %a during check()" Dns_trie.pp_err e) ;
       invalid_arg "check") ;
    let now = M.elapsed_ns mclock in
    let t = Dns_server.Primary.create now ~a:[ Dns_server.tsig_auth ] ~tsig_verify:Dns_tsig.verify ~tsig_sign:Dns_tsig.sign ~rng:R.generate trie in
    D.primary s pclock mclock t ;
    S.listen s
end
