open V1_LWT
open Lwt.Infix

let src = Logs.Src.create "server" ~doc:"DNS server"
module Log = (val Logs.src_log src : Logs.LOG)

let listening_port = 53

module Main (C : CONSOLE) (CLOCK: V1.PCLOCK) (S:STACKV4) = struct

  module U      = S.UDPV4
  module UDPLOG = Logs_syslog_mirage.Udp(C)(CLOCK)(S.UDPV4)

  let process dnstrie ~src:_src ~dst:_d d =
    let open Dns.Packet in
    Lwt.return
      (match d.questions with
       | [q] -> Dns.Protocol.contain_exc "answer"
                  (fun () -> Dns.Query.answer q.q_name q.q_type dnstrie)
       | _ -> None)

  let start con clock s =
    let udp = S.udpv4 s in
    let reporter =
      let ip = Ipaddr.V4.of_string_exn "198.167.222.206" in
      UDPLOG.create con clock udp ~hostname:"ns.nqsb.io" ip ~truncate:1484 ()
    in
    Logs.set_reporter reporter ;

    let process = process Zone.db.Dns.Loader.trie in
    let processor =
      let open Dns_server in
      (processor_of_process process :> (module PROCESSOR))
    in

    S.listen_udpv4 s ~port:listening_port (
      fun ~src ~dst ~src_port buf ->
        let r = Format.sprintf "%s:%d" (Ipaddr.V4.to_string src) src_port  in
        try
          let ba = Cstruct.to_bigarray buf in
          let packet = Dns.Packet.parse ba in
          Log.info (fun f -> f "%s query %s" r (Dns.Packet.to_string packet)) ;
          let src' = Ipaddr.V4 dst, listening_port
          and dst' = Ipaddr.V4 src, src_port
          and obuf = (Io_page.get 1 :> Dns.Buf.t)
          and l = Dns.Buf.length ba
          in
          Dns_server.process_query ba l obuf src' dst' processor >>= function
          | None -> Log.info (fun f -> f "%s no response" r); Lwt.return_unit
          | Some rba ->
            let rbuf = Cstruct.of_bigarray rba in
            (* in theory, this _could_ fail, but it is our very own answer... *)
            let reply = Dns.Packet.(to_string (parse rba)) in
            Log.info (fun f -> f "%s reply %s" r reply);
            let src_port = listening_port
            and dst = src
            and dst_port = src_port
            in
            U.write ~src_port ~dst ~dst_port udp rbuf >>= function
            | Error e ->
              Log.warn (fun f -> f "%s failure sending reply: %a"
                           r Mirage_pp.pp_udp_error e);
              Lwt.return_unit
            | Ok () -> Lwt.return_unit
        with e ->
          Log.warn (fun f -> f "%s exception %s" r (Printexc.to_string e));
          Lwt.return_unit);
    Log.info (fun f -> f "DNS server listening on UDP port %d" listening_port);
    S.listen s
end
