open Mirage_types_lwt
open Lwt.Infix

let src = Logs.Src.create "server" ~doc:"DNS server"
module Log = (val Logs.src_log src : Logs.LOG)

let listening_port = 53

module Main (S:STACKV4) = struct

  module U = S.UDPV4

  let process dnstrie ~src:_src ~dst:_d d =
    let open Dns.Packet in
    Lwt.return
      (match d.questions with
       | [q] -> Dns.Protocol.contain_exc "answer"
                  (fun () -> Dns.Query.answer q.q_name q.q_type dnstrie)
       | _ -> None)

  let start s _ =
    let udp = S.udpv4 s in
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
            if Cstruct.len rbuf > 1484 then
              (* otherwise solo5 assertions failure (if more than MTU bytes are send) *)
              (Log.warn (fun f -> f "%s tried to send a reply with more than 1484 bytes" r) ;
               Lwt.return_unit)
            else
              U.write ~src_port ~dst ~dst_port udp rbuf >|= function
              | Error e ->
                Log.warn (fun f -> f "%s failure sending reply: %a"
                             r U.pp_error e)
              | Ok () -> ()
        with e ->
          Log.warn (fun f -> f "%s exception %s" r (Printexc.to_string e));
          Lwt.return_unit);
    Log.info (fun f -> f "DNS server listening on UDP port %d" listening_port);
    S.listen s
end
