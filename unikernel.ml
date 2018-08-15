open Mirage_types_lwt

module Main (R : RANDOM) (P : PCLOCK) (M : MCLOCK) (T : TIME) (S : STACKV4) = struct

  module D = Dns_mirage_server.Make(P)(M)(T)(S)

  let data =
    let zone = Domain_name.of_string_exn "nqsb.io" in
    let n = Domain_name.prepend_exn zone
    and ip = Ipaddr.V4.of_string_exn
    and ss = Domain_name.Set.of_list
    in
    let ns = n "ns"
    and ttl = 2560l
    and ns' = n "sn"
    and mx = Domain_name.of_string_exn "mail.mehnert.org"
    in
    let soa = Dns_packet.({ nameserver = ns ;
                            hostmaster = n "hostmaster" ;
                            serial = 13l ; refresh = 16384l ; retry = 2048l ;
                            expiry = 1048576l ; minimum = ttl })
    in
    let open Dns_trie in
    let open Dns_map in
    let t = insert zone Soa (ttl, soa) Dns_trie.empty in
    let t = insert zone Ns (ttl, ss [ ns ; ns' ]) t in
    let t = insert ns A (ttl, [ ip "198.167.222.200" ]) t in
    let t = insert ns' A (ttl, [ ip "194.150.168.146" ]) t in
    let t = insert zone A (ttl, [ ip "198.167.222.201" ]) t in
    let t = insert zone Mx (ttl, [ (10, mx) ]) t in
    let t = insert (n "usenix15") A (ttl, [ ip "198.167.222.201" ]) t in
    let t = insert (n "tron") A (ttl, [ ip "198.167.222.201" ]) t in
    let t = insert (n "hannes") A (ttl, [ ip "198.167.222.205" ]) t in
    let t = insert (n "shell") A (ttl, [ ip "198.167.222.207" ]) t in
    let t = insert (n "kinda") A (ttl, [ ip "198.167.222.209" ]) t in
    let t = insert (n "tls") A (ttl, [ ip "198.167.222.210" ]) t in
    let t = insert (n "netsem") A (ttl, [ ip "198.167.222.213" ]) t in
    let t = insert (n "contao") A (ttl, [ ip "198.167.222.212" ]) t in
    let t = insert (n "hannes") Tlsa (ttl, [
        { Dns_packet.tlsa_cert_usage = Dns_enum.Domain_issued_certificate ;
          tlsa_selector = Dns_enum.Tlsa_selector_private ;
          tlsa_matching_type = Dns_enum.Tlsa_no_hash ;
          tlsa_data = Cstruct.of_hex "3082045e3082024602010030193117301506035504030c0e68616e6e65732e6e7173622e696f30820222300d06092a864886f70d01010105000382020f003082020a0282020100d8569367d73ee7144571ee671b856ea85e2a92342c7d0e57278e0cb9cf333766385700ab61aa1b1437f728040baf8016835f64ef4e487475849652a0c08f8d420ac1f200706798990b5dbb07c26e60d5086ee366540c2909e09d6965f71a573ff634ccb0fd889fad85e1bed9a0c7a32cf699fd8379ba866854b400079a30b022e82ee685692358342061befe43fefe36fcd3ef5305f4f4796de14eba8ae872570298680fd6fffcc258af6ffdbca0f0230b23728436ab9275e428403fca7b5e4a987a322ea599ed610f24068158d4b318a3106da271703e0cf4379e9366b61f1b3cf57874aa3ffb6e72667ef16852c8202812bdcc878188c357ff7a3bd6b0bd889bed1848839a81fd7c0f8fd7d5de5cc0e3503e9ac0bc3c58e7f3014d25667f800bee49edae6bf30b7887363674e79035976bbb1e9a812a9c48c997010fec71bb1e20002512e2b13c42b3095c0ebbe1df7fa828e691ab57b5ae9be66eeca79ceda2b7777282a601620a4eb7a23cf2ec6d9372d4ac4e28788f649d84f737bda35e736ee854126fd3ef487bf4129883d246fa0a9b5040f583dd15e8679b733600a8deed2f9796050a3fcf57d7e6407392f9e62dae9045ef2b8b8a589c7026a554e709c7a7d388d4ee145187e0e7c7b59792f7dea183fffc7be95d47826a3592e286263e351a6f08c90111c838424faee2838396296b8eea6158ede77e3bc3fbdfdb0203010001a000300d06092a864886f70d01010b0500038202010012540bff2ccd220bf6d26a9e3e0c7eeb5533426b22cc75e9154f143aa01881001d23018ab416c0507bae121044042a9472e964d0d5af859265d36eeb84c3b7e5f6e1f297977af7a43533fa0ed4447a490e8537078e634f9ee07e81565420074fb4dd04dffe5695543f10641ebf891ff74f0685ca8e6c6a4f995c5dab9df3f73b0169ad233e366f7805fce93b1460266b69c86e1a6e8ad2e6daaf34c746947c8197979bc8ad8c316e9c326191675dd8c1b77eaf8829d495a6b4ba1f6fcb580a564d3cc40534f0145c15954077435ce1da6bed85ecb6e32cf4d0948762be8203952f7722b802d25102257d3a97eb1e03d7f2759e60946bbdf078ef73868714269ff31ebe5694999309792b8aad245b1751acdc4f969dd1f483dc13b7df345bdba4550666e8fcfce2ab71b919ed3496012c2c07c84c331da0b3a8d5ca5762fe82ceaadabbdb24e2efbbd26f084be9ca006fbb01e21c561b2a211df09defa4c80c7ef47de65a97d07a5df2f12fcc205890bde924e8c34057765ab65fe51cea09c81b6b1db581f228c23dc6aa9666f204112a1b13bae302ceaa6f586bd280fdedad066f19b1e14764df131f26e98a8b5ddc1fc912cac6fabe4fdbf1c1eae7aa58c4a6a31448ef20f7f3af57639e88994f0a183e4d49b5acc264a45f17c6737fb5476c2ea810137cd6122a5c97c7f013a56d41606d6a94db6e37b713536523a60190e1"
        } ;
        { Dns_packet.tlsa_cert_usage = Dns_enum.Domain_issued_certificate ;
          tlsa_selector = Dns_enum.Tlsa_full_certificate ;
          tlsa_matching_type = Dns_enum.Tlsa_no_hash ;
          tlsa_data = Cstruct.of_hex "30820709308205f1a00302010202120368b315c4f999276cb829cecae36e4fa90f300d06092a864886f70d01010b0500304a310b300906035504061302555331163014060355040a130d4c6574277320456e6372797074312330210603550403131a4c6574277320456e637279707420417574686f72697479205833301e170d3138303730353230343630335a170d3138313030333230343630335a3019311730150603550403130e68616e6e65732e6e7173622e696f30820222300d06092a864886f70d01010105000382020f003082020a0282020100d8569367d73ee7144571ee671b856ea85e2a92342c7d0e57278e0cb9cf333766385700ab61aa1b1437f728040baf8016835f64ef4e487475849652a0c08f8d420ac1f200706798990b5dbb07c26e60d5086ee366540c2909e09d6965f71a573ff634ccb0fd889fad85e1bed9a0c7a32cf699fd8379ba866854b400079a30b022e82ee685692358342061befe43fefe36fcd3ef5305f4f4796de14eba8ae872570298680fd6fffcc258af6ffdbca0f0230b23728436ab9275e428403fca7b5e4a987a322ea599ed610f24068158d4b318a3106da271703e0cf4379e9366b61f1b3cf57874aa3ffb6e72667ef16852c8202812bdcc878188c357ff7a3bd6b0bd889bed1848839a81fd7c0f8fd7d5de5cc0e3503e9ac0bc3c58e7f3014d25667f800bee49edae6bf30b7887363674e79035976bbb1e9a812a9c48c997010fec71bb1e20002512e2b13c42b3095c0ebbe1df7fa828e691ab57b5ae9be66eeca79ceda2b7777282a601620a4eb7a23cf2ec6d9372d4ac4e28788f649d84f737bda35e736ee854126fd3ef487bf4129883d246fa0a9b5040f583dd15e8679b733600a8deed2f9796050a3fcf57d7e6407392f9e62dae9045ef2b8b8a589c7026a554e709c7a7d388d4ee145187e0e7c7b59792f7dea183fffc7be95d47826a3592e286263e351a6f08c90111c838424faee2838396296b8eea6158ede77e3bc3fbdfdb0203010001a382031830820314300e0603551d0f0101ff0404030205a0301d0603551d250416301406082b0601050507030106082b06010505070302300c0603551d130101ff04023000301d0603551d0e04160414710c449f077dbfccb53e3bfded47abff0c650edc301f0603551d23041830168014a84a6a63047dddbae6d139b7a64565eff3a8eca1306f06082b0601050507010104633061302e06082b060105050730018622687474703a2f2f6f6373702e696e742d78332e6c657473656e63727970742e6f7267302f06082b060105050730028623687474703a2f2f636572742e696e742d78332e6c657473656e63727970742e6f72672f30190603551d1104123010820e68616e6e65732e6e7173622e696f3081fe0603551d200481f63081f33008060667810c0102013081e6060b2b0601040182df130101013081d6302606082b06010505070201161a687474703a2f2f6370732e6c657473656e63727970742e6f72673081ab06082b0601050507020230819e0c819b54686973204365727469666963617465206d6179206f6e6c792062652072656c6965642075706f6e2062792052656c79696e67205061727469657320616e64206f6e6c7920696e206163636f7264616e636520776974682074686520436572746966696361746520506f6c69637920666f756e642061742068747470733a2f2f6c657473656e63727970742e6f72672f7265706f7369746f72792f30820106060a2b06010401d6790204020481f70481f400f2007700db74afeecb29ecb1feca3e716d2ce5b9aabb36f7847183c75d9d4f37b61fbf64000001646c68c9580000040300483046022100dff3ef732ac272b02d9b46ed64bf46f781bf0ebe3bf5e8e3e1fdabe94fd46b980221009ccc2792912854f45f635a5e7edff112d95b579b60fbe3bac1912a12c641f1be007700293c519654c83965baaa50fc5807d4b76fbf587a2972dca4c30cf4e54547f478000001646c68c969000004030048304602210092a1b1162f1fe2537a68e8bd54af6836847eefb29d3bfcb25d51248922e9a8bb022100ac026ef4debd6da841e3985dbd8233bc0da88be354642f79a8a0a64738d8825b300d06092a864886f70d01010b050003820101007e858316038f1981a3f1ef1ef2bad6ba467406ba7091a979903aa43bf79a140165458e4b83d8412d7efb760dad1400c9c891b595302902594e49325c6367f90adc29f91a69559a259ed5c08ed6f134f4a62bebaebb0e75e612553074f68fffae6e2b81341bdbab1ce9ce49238ecfbf5567b172e5650d83780f0b6a675e785d4199406bd69facdf2d83ca026b54a680bf51df46bde3dc8ff4e57f066fcd3cd05cc262eea0fb9f7ce46f3ff36573b1291b8cf2f5411fec306a2d226443ef27966abdd40825c91b46faa5f612fa528ad56935f4aad4f8b1ab0593208585102b9954e092fd5e636b73c49e647316d22cfb2e220da70086b9ab34ac3caed5dab88a6e"
        } ]) t
    in
    let t = insert (n "tls") Tlsa (ttl, [
        { Dns_packet.tlsa_cert_usage = Dns_enum.Domain_issued_certificate ;
          tlsa_selector = Dns_enum.Tlsa_selector_private ;
          tlsa_matching_type = Dns_enum.Tlsa_no_hash ;
          tlsa_data = Cstruct.of_hex "3082045b3082024302010030163114301206035504030c0b746c732e6e7173622e696f30820222300d06092a864886f70d01010105000382020f003082020a0282020100e9ac9fa94cb739309c2463574a640199f30fc6fca883d75e31bc877d57912a3db62c91e5d9defb9c7d056f42a1b82d320799a2627464990fad224957a3b47e22084ec3b38ac622cd2276a96b3d33e735dad524e038625daf2f6ebe35a9a492a3ad3b5ad8e6e3ccc7e1b8292ce93612647503ecd5578eac328e31c4ebed19d674516d57ab0c91d9c8c372e4ea6310b9fc5af5b833f32c680c79ee04a864345f7e33ef140e27cea27b5e498f34f9a2189362f11a25adefbdb29ee115bea986d0fe9ee7b2d157c6cca3438c06871a974a10d0e1b50274c3f929bb4c6b64a6195cb354f94751658e4377e6ca32836e90d5da98493b8472dd018bbec8baf6b94d10679ec725fc29ba0d22aa5e5d1607f62f067f9297110987133a160a476960c6ef57495e3a9279a1b2e5d66f0d2f70a95bb8890bb402fe12df2fc7a4e08c942f92d3fd1b2a6e8e5811c76f4309bb2b9e59183844e3a97af20f367732cba8d5739a658b8aeb8dec2614f553c9ad5accbb35d824d04db2a85aa24e75a4eaec222006c3f3a80f36c41c802309925b7d68febd83666c6eaf6bcf413610213aeeb0b4b4dfecaa46ecc9bec6b779497221a4f30f87cf7c69720460397a9b662546852b0c2ebbc27bbf52b30e3cafecb720fb1daccf99ae6c1bf46cc5611303a0043e7c6a618be2a07a427ad04140608fe9e641a9f498a68089519fa8627878ddbfb99342ad0203010001a000300d06092a864886f70d01010b0500038202010009e7fb4e9f8a05eb7af8244c1da0eeb1ab2862fc77aea03d15483fdcad766343f240238a19f14d0f076c03069f2aea6d03a93149441a36b4d85503d89ce572fcfb7dadcef750eccfe6dca4404a956c6d0be27187ed603cf2b0cdcd6dfa20b3d6a35732945c49941a134ad21b6ad6133559bf9fb6c884258515e01d33db09355f01e34ccd986afc83c270534561167f7a89aa4efbead98655ecffed319f5a37ce8fa31c41d3e9ed30a5a595fd7b1c8ac96b89c838c7f901bb876e59035ca824866a43882e450c53a24f2b433201b92f65680c5e37b0b146e6031082fd561e85fc68d6fcf30488dfd6c6b2a7cac475a502888f0a30901f8d77dd7738febb8738a1b52404dae5a698e47c8a07eb35ddde7d107daf8eaed479bd3d0f712e6099e927a7fa360b711533a80021fbc44e9af9cdd63d2377bb8bb0f493e7a7ae0618201a5a0e20cb1a5ceb5f4d7f9d38f9c9264837318203ac18ef2eae70632c9605f76318a87956b31d023ed593669a422606b9b847e3f98fc04048fe61463e1c730a032424387a476f7a1139befb2b91aa2e385b76c8d13e30c093acbf413ac9bbc5a11be4c8c5c0d710e1571e3599ee09ea1d9215355d8b51b17954a82295ff010e7fa5202ed67e23cacba897c6c56901fb3dcbeea744fad8b86e1c6bc217cb49db48a36a7220007fbded8ebe8d90ef7d5e5d454c61d2f563a6ab1d93c80453d961e6"
        } ;
        { Dns_packet.tlsa_cert_usage = Dns_enum.Domain_issued_certificate ;
          tlsa_selector = Dns_enum.Tlsa_full_certificate ;
          tlsa_matching_type = Dns_enum.Tlsa_no_hash ;
          tlsa_data = Cstruct.of_hex "30820702308205eaa003020102021203d0d77292fa4e1aee4414d1d78d36ad2a69300d06092a864886f70d01010b0500304a310b300906035504061302555331163014060355040a130d4c6574277320456e6372797074312330210603550403131a4c6574277320456e637279707420417574686f72697479205833301e170d3138303730353230333234385a170d3138313030333230333234385a3016311430120603550403130b746c732e6e7173622e696f30820222300d06092a864886f70d01010105000382020f003082020a0282020100e9ac9fa94cb739309c2463574a640199f30fc6fca883d75e31bc877d57912a3db62c91e5d9defb9c7d056f42a1b82d320799a2627464990fad224957a3b47e22084ec3b38ac622cd2276a96b3d33e735dad524e038625daf2f6ebe35a9a492a3ad3b5ad8e6e3ccc7e1b8292ce93612647503ecd5578eac328e31c4ebed19d674516d57ab0c91d9c8c372e4ea6310b9fc5af5b833f32c680c79ee04a864345f7e33ef140e27cea27b5e498f34f9a2189362f11a25adefbdb29ee115bea986d0fe9ee7b2d157c6cca3438c06871a974a10d0e1b50274c3f929bb4c6b64a6195cb354f94751658e4377e6ca32836e90d5da98493b8472dd018bbec8baf6b94d10679ec725fc29ba0d22aa5e5d1607f62f067f9297110987133a160a476960c6ef57495e3a9279a1b2e5d66f0d2f70a95bb8890bb402fe12df2fc7a4e08c942f92d3fd1b2a6e8e5811c76f4309bb2b9e59183844e3a97af20f367732cba8d5739a658b8aeb8dec2614f553c9ad5accbb35d824d04db2a85aa24e75a4eaec222006c3f3a80f36c41c802309925b7d68febd83666c6eaf6bcf413610213aeeb0b4b4dfecaa46ecc9bec6b779497221a4f30f87cf7c69720460397a9b662546852b0c2ebbc27bbf52b30e3cafecb720fb1daccf99ae6c1bf46cc5611303a0043e7c6a618be2a07a427ad04140608fe9e641a9f498a68089519fa8627878ddbfb99342ad0203010001a382031430820310300e0603551d0f0101ff0404030205a0301d0603551d250416301406082b0601050507030106082b06010505070302300c0603551d130101ff04023000301d0603551d0e0416041459aefe929481bb749dc010378f7d175792d30bac301f0603551d23041830168014a84a6a63047dddbae6d139b7a64565eff3a8eca1306f06082b0601050507010104633061302e06082b060105050730018622687474703a2f2f6f6373702e696e742d78332e6c657473656e63727970742e6f7267302f06082b060105050730028623687474703a2f2f636572742e696e742d78332e6c657473656e63727970742e6f72672f30160603551d11040f300d820b746c732e6e7173622e696f3081fe0603551d200481f63081f33008060667810c0102013081e6060b2b0601040182df130101013081d6302606082b06010505070201161a687474703a2f2f6370732e6c657473656e63727970742e6f72673081ab06082b0601050507020230819e0c819b54686973204365727469666963617465206d6179206f6e6c792062652072656c6965642075706f6e2062792052656c79696e67205061727469657320616e64206f6e6c7920696e206163636f7264616e636520776974682074686520436572746966696361746520506f6c69637920666f756e642061742068747470733a2f2f6c657473656e63727970742e6f72672f7265706f7369746f72792f30820105060a2b06010401d6790204020481f60481f300f1007700db74afeecb29ecb1feca3e716d2ce5b9aabb36f7847183c75d9d4f37b61fbf64000001646c5ca4bf0000040300483046022100ee5eea6a16a0e4838216a1f5bc3f21a232d131868c115480889b7543e83f8ca7022100e17009abafb797ca2260669fe5cec9297ba37a21cf6b88883b922f03dbe40a40007600293c519654c83965baaa50fc5807d4b76fbf587a2972dca4c30cf4e54547f478000001646c5ca4be0000040300473045022100b4e19aa3593206771c4212dff843eef6f07842fdea6e5329d0a4b3a97cd684f0022002154125414c27e44d45f35a931e4f7651d4cf2fd5f578183516bb2bcc8983bf300d06092a864886f70d01010b0500038201010089e6acf31034315d820fff3403989cc8c395552e83f0376fa1bf21519fd3383767cebb6278d78c2c9e6d170e1b7ad53f4ad951eade7d8f327cbeceee70ef8a7c7b12a838d781a5869a7f0c4cbd45fcdf63d184d5a55370174f3f34952310c39674faaf67530a74a6c5856af6786255d80afa9cc4980111f82be77fc3d7bb59eff2a934fa0ebdc42f83c9accc3f84587b97ef691c2f7abac40e6af2e9aea72a2abbccea6b2d2b19c2a29806e0143dc609223dc25924a69f371e459d379599d546c5c39ad41662885d48882c964f0255f3f3cf857b020add2923916960dae42d3df2defcee22f1affe72bd1743195fa5842f23819a3159b66443e878f9d3aae1d0"
        } ]) t
    in
    t

  let process_key acc key =
    match Astring.String.cut ~sep:":" key with
    | None -> Logs.err (fun m -> m "couldn't parse key %s" key) ; acc
    | Some (name, dnskey) -> match Domain_name.of_string ~hostname:false name, Dns_packet.dnskey_of_string dnskey with
      | Error _, _ | _, None -> Logs.err (fun m -> m "failed to parse key %s" key) ; acc
      | Ok name, Some k ->
        Logs.info (fun m -> m "inserted %a %a" Domain_name.pp name Dns_packet.pp_dnskey k) ;
        (name, k) :: acc

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
    let keys = List.fold_left process_key [] (Key_gen.keys ()) in
    let t =
      UDns_server.Primary.create ~keys ~a:[UDns_server.Authentication.tsig_auth]
        ~tsig_verify:Dns_tsig.verify ~tsig_sign:Dns_tsig.sign
        ~rng:R.generate trie
    in
    D.primary s pclock mclock t ;
    S.listen s
end
