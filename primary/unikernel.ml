open Mirage_types_lwt

module Main (R : RANDOM) (P : PCLOCK) (M : MCLOCK) (T : TIME) (S : STACKV4) = struct

  module D = Dns_mirage_server.Make(P)(M)(T)(S)

  let data =
    let zone = Domain_name.of_string_exn "nqsb.io" in
    let n = Domain_name.prepend_exn zone
    and ip = Ipaddr.V4.of_string_exn
    in
    let ip_set i = Dns_map.Ipv4Set.singleton (ip i) in
    let ns = n "ns"
    and ttl = 2560l
    and ns' = n "sn"
    and mx = Domain_name.of_string_exn "mail.mehnert.org"
    in
    let soa = Dns_packet.({ nameserver = ns ;
                            hostmaster = n "hostmaster" ;
                            serial = 456l ; refresh = 16384l ; retry = 2048l ;
                            expiry = 1048576l ; minimum = ttl })
    in
    let open Dns_trie in
    let open Dns_map in
    let t = insert zone Soa (ttl, soa) Dns_trie.empty in
    let t = insert zone Ns (ttl, Domain_name.Set.(add ns (singleton ns'))) t in
    let t = insert ns A (ttl, ip_set "198.167.222.200") t in
    let t = insert ns' A (ttl, ip_set "194.150.168.146") t in
    let t = insert zone A (ttl, ip_set "198.167.222.201") t in
    let t = insert zone Mx (ttl, MxSet.singleton (10, mx)) t in
    let t = insert (n "usenix15") A (ttl, ip_set "198.167.222.201") t in
    let t = insert (n "tron") A (ttl, ip_set "198.167.222.201") t in
    let t = insert (n "hannes") A (ttl, ip_set "198.167.222.205") t in
    let t = insert (n "shell") A (ttl, ip_set "198.167.222.207") t in
    let t = insert (n "kinda") A (ttl, ip_set "198.167.222.209") t in
    let t = insert (n "tls") A (ttl, ip_set "198.167.222.210") t in
    let t = insert (n "netsem") A (ttl, ip_set "198.167.222.213") t in
    let t = insert (n "contao") A (ttl, ip_set "198.167.222.212") t in
    let t =
      let tlsas = TlsaSet.add
          { Dns_packet.tlsa_cert_usage = Dns_enum.Domain_issued_certificate ;
            tlsa_selector = Dns_enum.Tlsa_selector_private ;
            tlsa_matching_type = Dns_enum.Tlsa_no_hash ;
            tlsa_data = Cstruct.of_hex "3082045e3082024602010030193117301506035504030c0e68616e6e65732e6e7173622e696f30820222300d06092a864886f70d01010105000382020f003082020a0282020100d8569367d73ee7144571ee671b856ea85e2a92342c7d0e57278e0cb9cf333766385700ab61aa1b1437f728040baf8016835f64ef4e487475849652a0c08f8d420ac1f200706798990b5dbb07c26e60d5086ee366540c2909e09d6965f71a573ff634ccb0fd889fad85e1bed9a0c7a32cf699fd8379ba866854b400079a30b022e82ee685692358342061befe43fefe36fcd3ef5305f4f4796de14eba8ae872570298680fd6fffcc258af6ffdbca0f0230b23728436ab9275e428403fca7b5e4a987a322ea599ed610f24068158d4b318a3106da271703e0cf4379e9366b61f1b3cf57874aa3ffb6e72667ef16852c8202812bdcc878188c357ff7a3bd6b0bd889bed1848839a81fd7c0f8fd7d5de5cc0e3503e9ac0bc3c58e7f3014d25667f800bee49edae6bf30b7887363674e79035976bbb1e9a812a9c48c997010fec71bb1e20002512e2b13c42b3095c0ebbe1df7fa828e691ab57b5ae9be66eeca79ceda2b7777282a601620a4eb7a23cf2ec6d9372d4ac4e28788f649d84f737bda35e736ee854126fd3ef487bf4129883d246fa0a9b5040f583dd15e8679b733600a8deed2f9796050a3fcf57d7e6407392f9e62dae9045ef2b8b8a589c7026a554e709c7a7d388d4ee145187e0e7c7b59792f7dea183fffc7be95d47826a3592e286263e351a6f08c90111c838424faee2838396296b8eea6158ede77e3bc3fbdfdb0203010001a000300d06092a864886f70d01010b0500038202010012540bff2ccd220bf6d26a9e3e0c7eeb5533426b22cc75e9154f143aa01881001d23018ab416c0507bae121044042a9472e964d0d5af859265d36eeb84c3b7e5f6e1f297977af7a43533fa0ed4447a490e8537078e634f9ee07e81565420074fb4dd04dffe5695543f10641ebf891ff74f0685ca8e6c6a4f995c5dab9df3f73b0169ad233e366f7805fce93b1460266b69c86e1a6e8ad2e6daaf34c746947c8197979bc8ad8c316e9c326191675dd8c1b77eaf8829d495a6b4ba1f6fcb580a564d3cc40534f0145c15954077435ce1da6bed85ecb6e32cf4d0948762be8203952f7722b802d25102257d3a97eb1e03d7f2759e60946bbdf078ef73868714269ff31ebe5694999309792b8aad245b1751acdc4f969dd1f483dc13b7df345bdba4550666e8fcfce2ab71b919ed3496012c2c07c84c331da0b3a8d5ca5762fe82ceaadabbdb24e2efbbd26f084be9ca006fbb01e21c561b2a211df09defa4c80c7ef47de65a97d07a5df2f12fcc205890bde924e8c34057765ab65fe51cea09c81b6b1db581f228c23dc6aa9666f204112a1b13bae302ceaa6f586bd280fdedad066f19b1e14764df131f26e98a8b5ddc1fc912cac6fabe4fdbf1c1eae7aa58c4a6a31448ef20f7f3af57639e88994f0a183e4d49b5acc264a45f17c6737fb5476c2ea810137cd6122a5c97c7f013a56d41606d6a94db6e37b713536523a60190e1"
          }
          (TlsaSet.singleton
             { Dns_packet.tlsa_cert_usage = Dns_enum.Domain_issued_certificate ;
               tlsa_selector = Dns_enum.Tlsa_full_certificate ;
               tlsa_matching_type = Dns_enum.Tlsa_no_hash ;
               tlsa_data = Cstruct.of_hex "30820706308205eea003020102021203a8416c259f9569a02e6b6fbf4a04a42b6c300d06092a864886f70d01010b0500304a310b300906035504061302555331163014060355040a130d4c6574277320456e6372797074312330210603550403131a4c6574277320456e637279707420417574686f72697479205833301e170d3138313031343135333833345a170d3139303131323135333833345a3019311730150603550403130e68616e6e65732e6e7173622e696f30820222300d06092a864886f70d01010105000382020f003082020a0282020100d8569367d73ee7144571ee671b856ea85e2a92342c7d0e57278e0cb9cf333766385700ab61aa1b1437f728040baf8016835f64ef4e487475849652a0c08f8d420ac1f200706798990b5dbb07c26e60d5086ee366540c2909e09d6965f71a573ff634ccb0fd889fad85e1bed9a0c7a32cf699fd8379ba866854b400079a30b022e82ee685692358342061befe43fefe36fcd3ef5305f4f4796de14eba8ae872570298680fd6fffcc258af6ffdbca0f0230b23728436ab9275e428403fca7b5e4a987a322ea599ed610f24068158d4b318a3106da271703e0cf4379e9366b61f1b3cf57874aa3ffb6e72667ef16852c8202812bdcc878188c357ff7a3bd6b0bd889bed1848839a81fd7c0f8fd7d5de5cc0e3503e9ac0bc3c58e7f3014d25667f800bee49edae6bf30b7887363674e79035976bbb1e9a812a9c48c997010fec71bb1e20002512e2b13c42b3095c0ebbe1df7fa828e691ab57b5ae9be66eeca79ceda2b7777282a601620a4eb7a23cf2ec6d9372d4ac4e28788f649d84f737bda35e736ee854126fd3ef487bf4129883d246fa0a9b5040f583dd15e8679b733600a8deed2f9796050a3fcf57d7e6407392f9e62dae9045ef2b8b8a589c7026a554e709c7a7d388d4ee145187e0e7c7b59792f7dea183fffc7be95d47826a3592e286263e351a6f08c90111c838424faee2838396296b8eea6158ede77e3bc3fbdfdb0203010001a382031530820311300e0603551d0f0101ff0404030205a0301d0603551d250416301406082b0601050507030106082b06010505070302300c0603551d130101ff04023000301d0603551d0e04160414710c449f077dbfccb53e3bfded47abff0c650edc301f0603551d23041830168014a84a6a63047dddbae6d139b7a64565eff3a8eca1306f06082b0601050507010104633061302e06082b060105050730018622687474703a2f2f6f6373702e696e742d78332e6c657473656e63727970742e6f7267302f06082b060105050730028623687474703a2f2f636572742e696e742d78332e6c657473656e63727970742e6f72672f30190603551d1104123010820e68616e6e65732e6e7173622e696f3081fe0603551d200481f63081f33008060667810c0102013081e6060b2b0601040182df130101013081d6302606082b06010505070201161a687474703a2f2f6370732e6c657473656e63727970742e6f72673081ab06082b0601050507020230819e0c819b54686973204365727469666963617465206d6179206f6e6c792062652072656c6965642075706f6e2062792052656c79696e67205061727469657320616e64206f6e6c7920696e206163636f7264616e636520776974682074686520436572746966696361746520506f6c69637920666f756e642061742068747470733a2f2f6c657473656e63727970742e6f72672f7265706f7369746f72792f30820103060a2b06010401d6790204020481f40481f100ef007500747eda8331ad331091219cce254f4270c2bffd5e422008c6373579e6107bcc560000016673719020000004030046304402206774a674071d5d64fb63bc3e5f980e79b1d8e69308805865e4fd60b236b0039302206224eb6b376fecc60d435bb0094a87180da4e0fdedf1ac5d9c5ea3dea2a13c98007600293c519654c83965baaa50fc5807d4b76fbf587a2972dca4c30cf4e54547f4780000016673718fb60000040300473045022100a8721ac056b4a3c0a6c46b66c31f248c9cc5bb9ffcc5ad4c0b2962c12bd1960202203efa64cc5822c46bc891759d4521e6635dc3dbc9c197ec126b08d9acdaf68e04300d06092a864886f70d01010b0500038201010048631d8ca58549b30c1e2eb27515bbf89976e64e176e6c16cfa3bb2f87d0ec58b3c86c440cec2c4f53f0c283992358cd4e1b28979c3a8da04040d8aee01391118a88193aaafec60d3b60a61ab571de1bd68ac15ce4b65b93d093dce4f0d6ba797234bd5c6e71a3d34699b79320a60f07dc8fb1e1cce89e9dfa5f53044ee1432f988c1857d9206eda58a519d276b95aebe26f307e32615b0bd15eca0a728c92b257102e118de17199cabe5bd182592be2fd82fb8357434b0e28f8adf5fbe7a0fcb539900bc911c5f8dd6f84a34745ba5045276f000619aacf6e531e00e96751f8e4e055018472930bd4952c79a0cc3958ee18ff28d38bd44fe7f1215a69c14225"
             })
      in
      insert (n "hannes") Tlsa (ttl, tlsas) t
    in
    let t =
      let tlsas = TlsaSet.add
        { Dns_packet.tlsa_cert_usage = Dns_enum.Domain_issued_certificate ;
          tlsa_selector = Dns_enum.Tlsa_selector_private ;
          tlsa_matching_type = Dns_enum.Tlsa_no_hash ;
          tlsa_data = Cstruct.of_hex "3082045b3082024302010030163114301206035504030c0b746c732e6e7173622e696f30820222300d06092a864886f70d01010105000382020f003082020a0282020100e9ac9fa94cb739309c2463574a640199f30fc6fca883d75e31bc877d57912a3db62c91e5d9defb9c7d056f42a1b82d320799a2627464990fad224957a3b47e22084ec3b38ac622cd2276a96b3d33e735dad524e038625daf2f6ebe35a9a492a3ad3b5ad8e6e3ccc7e1b8292ce93612647503ecd5578eac328e31c4ebed19d674516d57ab0c91d9c8c372e4ea6310b9fc5af5b833f32c680c79ee04a864345f7e33ef140e27cea27b5e498f34f9a2189362f11a25adefbdb29ee115bea986d0fe9ee7b2d157c6cca3438c06871a974a10d0e1b50274c3f929bb4c6b64a6195cb354f94751658e4377e6ca32836e90d5da98493b8472dd018bbec8baf6b94d10679ec725fc29ba0d22aa5e5d1607f62f067f9297110987133a160a476960c6ef57495e3a9279a1b2e5d66f0d2f70a95bb8890bb402fe12df2fc7a4e08c942f92d3fd1b2a6e8e5811c76f4309bb2b9e59183844e3a97af20f367732cba8d5739a658b8aeb8dec2614f553c9ad5accbb35d824d04db2a85aa24e75a4eaec222006c3f3a80f36c41c802309925b7d68febd83666c6eaf6bcf413610213aeeb0b4b4dfecaa46ecc9bec6b779497221a4f30f87cf7c69720460397a9b662546852b0c2ebbc27bbf52b30e3cafecb720fb1daccf99ae6c1bf46cc5611303a0043e7c6a618be2a07a427ad04140608fe9e641a9f498a68089519fa8627878ddbfb99342ad0203010001a000300d06092a864886f70d01010b0500038202010009e7fb4e9f8a05eb7af8244c1da0eeb1ab2862fc77aea03d15483fdcad766343f240238a19f14d0f076c03069f2aea6d03a93149441a36b4d85503d89ce572fcfb7dadcef750eccfe6dca4404a956c6d0be27187ed603cf2b0cdcd6dfa20b3d6a35732945c49941a134ad21b6ad6133559bf9fb6c884258515e01d33db09355f01e34ccd986afc83c270534561167f7a89aa4efbead98655ecffed319f5a37ce8fa31c41d3e9ed30a5a595fd7b1c8ac96b89c838c7f901bb876e59035ca824866a43882e450c53a24f2b433201b92f65680c5e37b0b146e6031082fd561e85fc68d6fcf30488dfd6c6b2a7cac475a502888f0a30901f8d77dd7738febb8738a1b52404dae5a698e47c8a07eb35ddde7d107daf8eaed479bd3d0f712e6099e927a7fa360b711533a80021fbc44e9af9cdd63d2377bb8bb0f493e7a7ae0618201a5a0e20cb1a5ceb5f4d7f9d38f9c9264837318203ac18ef2eae70632c9605f76318a87956b31d023ed593669a422606b9b847e3f98fc04048fe61463e1c730a032424387a476f7a1139befb2b91aa2e385b76c8d13e30c093acbf413ac9bbc5a11be4c8c5c0d710e1571e3599ee09ea1d9215355d8b51b17954a82295ff010e7fa5202ed67e23cacba897c6c56901fb3dcbeea744fad8b86e1c6bc217cb49db48a36a7220007fbded8ebe8d90ef7d5e5d454c61d2f563a6ab1d93c80453d961e6"
        }
        (TlsaSet.singleton
           { Dns_packet.tlsa_cert_usage = Dns_enum.Domain_issued_certificate ;
             tlsa_selector = Dns_enum.Tlsa_full_certificate ;
             tlsa_matching_type = Dns_enum.Tlsa_no_hash ;
             tlsa_data = Cstruct.of_hex "30820701308205e9a003020102021203aab1eaa58f1a42d121d9c271f1533cc236300d06092a864886f70d01010b0500304a310b300906035504061302555331163014060355040a130d4c6574277320456e6372797074312330210603550403131a4c6574277320456e637279707420417574686f72697479205833301e170d3138313031343135353131305a170d3139303131323135353131305a3016311430120603550403130b746c732e6e7173622e696f30820222300d06092a864886f70d01010105000382020f003082020a0282020100e9ac9fa94cb739309c2463574a640199f30fc6fca883d75e31bc877d57912a3db62c91e5d9defb9c7d056f42a1b82d320799a2627464990fad224957a3b47e22084ec3b38ac622cd2276a96b3d33e735dad524e038625daf2f6ebe35a9a492a3ad3b5ad8e6e3ccc7e1b8292ce93612647503ecd5578eac328e31c4ebed19d674516d57ab0c91d9c8c372e4ea6310b9fc5af5b833f32c680c79ee04a864345f7e33ef140e27cea27b5e498f34f9a2189362f11a25adefbdb29ee115bea986d0fe9ee7b2d157c6cca3438c06871a974a10d0e1b50274c3f929bb4c6b64a6195cb354f94751658e4377e6ca32836e90d5da98493b8472dd018bbec8baf6b94d10679ec725fc29ba0d22aa5e5d1607f62f067f9297110987133a160a476960c6ef57495e3a9279a1b2e5d66f0d2f70a95bb8890bb402fe12df2fc7a4e08c942f92d3fd1b2a6e8e5811c76f4309bb2b9e59183844e3a97af20f367732cba8d5739a658b8aeb8dec2614f553c9ad5accbb35d824d04db2a85aa24e75a4eaec222006c3f3a80f36c41c802309925b7d68febd83666c6eaf6bcf413610213aeeb0b4b4dfecaa46ecc9bec6b779497221a4f30f87cf7c69720460397a9b662546852b0c2ebbc27bbf52b30e3cafecb720fb1daccf99ae6c1bf46cc5611303a0043e7c6a618be2a07a427ad04140608fe9e641a9f498a68089519fa8627878ddbfb99342ad0203010001a38203133082030f300e0603551d0f0101ff0404030205a0301d0603551d250416301406082b0601050507030106082b06010505070302300c0603551d130101ff04023000301d0603551d0e0416041459aefe929481bb749dc010378f7d175792d30bac301f0603551d23041830168014a84a6a63047dddbae6d139b7a64565eff3a8eca1306f06082b0601050507010104633061302e06082b060105050730018622687474703a2f2f6f6373702e696e742d78332e6c657473656e63727970742e6f7267302f06082b060105050730028623687474703a2f2f636572742e696e742d78332e6c657473656e63727970742e6f72672f30160603551d11040f300d820b746c732e6e7173622e696f3081fe0603551d200481f63081f33008060667810c0102013081e6060b2b0601040182df130101013081d6302606082b06010505070201161a687474703a2f2f6370732e6c657473656e63727970742e6f72673081ab06082b0601050507020230819e0c819b54686973204365727469666963617465206d6179206f6e6c792062652072656c6965642075706f6e2062792052656c79696e67205061727469657320616e64206f6e6c7920696e206163636f7264616e636520776974682074686520436572746966696361746520506f6c69637920666f756e642061742068747470733a2f2f6c657473656e63727970742e6f72672f7265706f7369746f72792f30820104060a2b06010401d6790204020481f50481f200f00076006f5376ac31f03119d89900a45115ff77151c11d902c10029068db2089a37d91300000166737d1bd00000040300473045022100c80da12bb52650c6e7813bd2ec6b81392f31ebfb9ea1208a4760ae073f22d3c302206b79abdea9f78e32172f239fbe9b79e2fcd2810b0ac5caaaf1668ba60bce9523007600293c519654c83965baaa50fc5807d4b76fbf587a2972dca4c30cf4e54547f47800000166737d1c8300000403004730450220285dc9f6f978edc34c74710bf51ae4942294c27e077bbc5be0b58c05a1e48d98022100bdc9d83fb6e55af8874011b8ce27c68dca352d908923e67408398b0cc530f94a300d06092a864886f70d01010b0500038201010027e1c2c2b02da8d4a69225a984c56798526b24822d81ce3be313d9956ee10a98a26a0c6ec7c5b34c40b821afc87e1c7cbe0e93a8f66d25c04ebc9af901f4a9c079b6052688ef8081a5847544d183d6757606cd1d72451ac05fe79a48a4163ef8fae8cbaa827388fe7c5bd7fff39982141c5e5106f9f8e00d7d3aef5d9d36e40ff16c6e9dc3f5b2b24f01ae0a5edc920cc9437996c2269c8dca882973c795210582149dbcc66eb8a6afa1d67a039734dad8db0abe577f576a491441d6c3ba791c928265b351894f185c2530b11552b97c3341a8b094e78eacf112cac2fe23a8ac17afdcab6ef82e5b585e71f0827d597ccdcdb394d278beacd7d6d9bca1b9a948"
           })
      in
      insert (n "tls") Tlsa (ttl, tlsas) t
    in
    let t =
      let tlsas = TlsaSet.add
        { Dns_packet.tlsa_cert_usage = Dns_enum.Domain_issued_certificate ;
          tlsa_selector = Dns_enum.Tlsa_selector_private ;
          tlsa_matching_type = Dns_enum.Tlsa_no_hash ;
          tlsa_data = Cstruct.of_hex "3082049c3082028402010030123110300e06035504030c076e7173622e696f30820222300d06092a864886f70d01010105000382020f003082020a0282020100f60065c7b28451a2ac5f17f8e86cdcac6ad6a304c79ad063c56b136c681af22d03353ae3afb300d9cbdc862c73bd7ab548f79b311805ff6c31fb0122bea15ee1dba783d606c4018a65570b6211bf7950bc77a37c2d77690aa3799137a0883b9a3a86005aa744415541449ba9d581264c88a9747d84d2b295404afa5135c60fc80c176e62d1480305cab3ccb80ac4f97073896e8d5bb143f69cc808b7860cbf0157facc9e57a7f29bc6e2ebcf19ae6e0925c2b9e29e7afc581334299442a47bbd606ee333b404eb9cf7447ab9f5be30c02eb147abee1dc9322beb469b65022426d132193d4f177890166cbc7126ac5d2fd46aa3408708c2f5c6e87a2f1c44053d7a4964b8689f9eab7f46f335046be46a76c9f98d3475879506fbc286abe350feeb68881c55a07e0d85f3fe8a4497ab0a955d65530af6afb3f97d6dbd979a4a834565706c08511ee238f2c18907ccfe74a83e0af833113e8875cec66978b2ed897c10fb9822354ca16d89c910f2d505ef7063dd1b882088f2492847571bf4d025d9d5d1e36bd0b448d6e170a821f44c688cfa7a2aac5fcf251003369f1cbc327ffe3c671c90063bf42081e8399ee4a2a0c3fc18357307ff330a7517e877d31c85a767183740341d7eead2b6fb884728d71940f1024f455f5dcd0283ac7e18ccb98a28128c6ad4cd3ef2c5cb1a4ec162bbfeae44de88bef2505e9a6d36c806e3070203010001a045304306092a864886f70d01090e3136303430320603551d11042b302982076e7173622e696f820c74726f6e2e6e7173622e696f82107573656e697831352e6e7173622e696f300d06092a864886f70d01010b05000382020100e8395b6efce43ce2b9c8196a325a695b894716844ef91ffbeb2107716dacf7b4d85773d7749fc9c46a54c50c9fea402646d9d41e539eb9c459a1f175a442589940e4734431d6700029946f42fe636cf03ad19fda78cdaf3f1dc22a83d23f7c6ff3e05cee26c65c68d222332a04c22ba2fa2fbd7ea881746596f0f4810a8fd818ca7c547fa73b38f16a8fbb8d19fb3433f67bc5ca0c6a606604ef3ac838fafeb1c98c63075d743d55a2af8cca18f7160336f90f864a91f7da1fa3ee072a9cefd63c9ca070fc2905917638311826af37b9910a6ff6b393e935a663f67e6d35ed2bba86f83afb35126162ff03ccd11f1f0553a40089fbbcb6092d4abfc020eb60a7219ec9d5ce04990936e3d1c997f344459320a2fd41740957427352145360c5dfe9b97651f3fffe89f653667adc1260bb4eeb357fb1e77244501cd5fdf201875c20d49c69d7233c113ad2055e90a1f862d9c2a7308d1debf89f8c9616742ffdeb4bf5374a2c5ec8df08f4ee273987b71e149cdabbb75e221e827eddb5c8c9dc003f1487bcd090534b237e827421006455c48e2bb8358036297c5bf70c7f4157c0070bf5a9562a54dc953f51cc8397270a501c34fbd09fff6593e54080ff04687d0434e6abbdc8d15ca82d568706575fab5832a6c685e1106be2adb19fb6ff635010547e388669951c9882cbc2f17b59867ab1efbd7015805ab644c086272e1ecb"
        }
        (TlsaSet.singleton
           { Dns_packet.tlsa_cert_usage = Dns_enum.Domain_issued_certificate ;
             tlsa_selector = Dns_enum.Tlsa_full_certificate ;
             tlsa_matching_type = Dns_enum.Tlsa_no_hash ;
             tlsa_data = Cstruct.of_hex "308206663082054ea00302010202120469e1a0f77119344acafe1afd58a9269882300d06092a864886f70d01010b0500304a310b300906035504061302555331163014060355040a130d4c6574277320456e6372797074312330210603550403131a4c6574277320456e637279707420417574686f72697479205833301e170d3138313232333133313333365a170d3139303332333133313333365a30123110300e060355040313076e7173622e696f30820222300d06092a864886f70d01010105000382020f003082020a0282020100f60065c7b28451a2ac5f17f8e86cdcac6ad6a304c79ad063c56b136c681af22d03353ae3afb300d9cbdc862c73bd7ab548f79b311805ff6c31fb0122bea15ee1dba783d606c4018a65570b6211bf7950bc77a37c2d77690aa3799137a0883b9a3a86005aa744415541449ba9d581264c88a9747d84d2b295404afa5135c60fc80c176e62d1480305cab3ccb80ac4f97073896e8d5bb143f69cc808b7860cbf0157facc9e57a7f29bc6e2ebcf19ae6e0925c2b9e29e7afc581334299442a47bbd606ee333b404eb9cf7447ab9f5be30c02eb147abee1dc9322beb469b65022426d132193d4f177890166cbc7126ac5d2fd46aa3408708c2f5c6e87a2f1c44053d7a4964b8689f9eab7f46f335046be46a76c9f98d3475879506fbc286abe350feeb68881c55a07e0d85f3fe8a4497ab0a955d65530af6afb3f97d6dbd979a4a834565706c08511ee238f2c18907ccfe74a83e0af833113e8875cec66978b2ed897c10fb9822354ca16d89c910f2d505ef7063dd1b882088f2492847571bf4d025d9d5d1e36bd0b448d6e170a821f44c688cfa7a2aac5fcf251003369f1cbc327ffe3c671c90063bf42081e8399ee4a2a0c3fc18357307ff330a7517e877d31c85a767183740341d7eead2b6fb884728d71940f1024f455f5dcd0283ac7e18ccb98a28128c6ad4cd3ef2c5cb1a4ec162bbfeae44de88bef2505e9a6d36c806e3070203010001a382027c30820278300e0603551d0f0101ff0404030205a0301d0603551d250416301406082b0601050507030106082b06010505070302300c0603551d130101ff04023000301d0603551d0e0416041451c0263c9c40b3d0299187e91a755697c2e16b9c301f0603551d23041830168014a84a6a63047dddbae6d139b7a64565eff3a8eca1306f06082b0601050507010104633061302e06082b060105050730018622687474703a2f2f6f6373702e696e742d78332e6c657473656e63727970742e6f7267302f06082b060105050730028623687474703a2f2f636572742e696e742d78332e6c657473656e63727970742e6f72672f30320603551d11042b302982076e7173622e696f820c74726f6e2e6e7173622e696f82107573656e697831352e6e7173622e696f304c0603551d20044530433008060667810c0102013037060b2b0601040182df130101013028302606082b06010505070201161a687474703a2f2f6370732e6c657473656e63727970742e6f726730820104060a2b06010401d6790204020481f50481f200f0007600747eda8331ad331091219cce254f4270c2bffd5e422008c6373579e6107bcc5600000167db69ffb000000403004730450220730779eb0250b15866379e725e2d79069b3a4b59a52e2b78307602ab1c5620c9022100cbe721678008bbeb72b042f02c96d012eb2c018271407c636ff845100609515c00760063f2dbcde83bcc2ccf0b728427576b33a48d61778fbd75a638b1c768544bd88d00000167db6a00190000040300473045022100bebf2012e8d962939ca45d4a2f6ff68e5fef8c17956493d72df1110b0ff1946202202dd078491b2c2edea4316b10005074f38bd532914478467f3da3f82605196b60300d06092a864886f70d01010b050003820101005b98bd70f39cea05e161bb3dabe3e56cacbe9be49b21c6444a1ec2063ec14e02d8c1b4ef22b5b6a1e8308f27989a33f448ec52aeb94663cbff3ebf67021d60d327749a0ee191b84b758980b0ea1e6de37130fd63d3258020b03b88c3ca96b9f178b74a65dcbfdddad534f933401e6350fbe9ce947183c6f75ce2cd21833b208ff184091bc9297e954d7af95ea46338bd73d1d713f2619b9d1506ad382a6be9e9ac6d6b190de48657b1f42f95e88c016958589e5dc02c5f68e18de4b339bd2e905e47f500f712e57cb663c064ff85a1f4d1bdc4f2c0890282ecb550ad3df28f691e29aee5964f0c9e2671b685df5d0bf31a1b34e12c93dbfc2f1f8a66a6909a5c"
           })
      in
      insert zone Tlsa (ttl, tlsas) t
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
