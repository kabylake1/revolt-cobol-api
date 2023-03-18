      *WebSockets context creation info
       >>DEFINE WEBSOCKET-ABI "5"
       >>IF WEBSOCKET-ABI = "5"
       :levl: :pref:-info.
           45 :pref:-port
               :tp-int: synchronized.
           45 :pref:-iface usage is pointer synchronized.
           45 :pref:-protocols usage is pointer synchronized.
           45 :pref:-extensions usage is pointer synchronized.
           45 :pref:-token-limits usage is pointer synchronized.
           45 :pref:-ssl-private-key-password
               usage is pointer synchronized.
           45 :pref:-ssl-cert-filepath usage is pointer synchronized.
           45 :pref:-ssl-private-key-filepath
               usage is pointer synchronized.
           45 :pref:-ssl-ca-filepath usage is pointer synchronized.
           45 :pref:-ssl-cipher-list usage is pointer synchronized.
           45 :pref:-http-proxy-address usage is pointer synchronized.
           45 :pref:-http-proxy-port
               :tp-uint: synchronized.
           45 :pref:-gid
               :tp-int: synchronized.
           45 :pref:-uid
               :tp-int: synchronized.
           45 :pref:-options
               :tp-uint64: synchronized.
           45 :pref:-userdata usage is pointer synchronized.
           45 :pref:-ka-time
               :tp-int: synchronized.
           45 :pref:-ka-probes
               :tp-int: synchronized.
           45 :pref:-ka-intervals
               :tp-int: synchronized.
           45 :pref:-provided-client-tls-ctx
               usage is pointer synchronized.
           45 :pref:-max-http-header-data
               :tp-ush: synchronized.
           45 :pref:-max-http-header-pool
               :tp-ush: synchronized.
           45 :pref:-count-threads
               :tp-uint: synchronized.
           45 :pref:-fd-limit-per-thread
               :tp-uint: synchronized.
           45 :pref:-timeout-secs
               :tp-uint: synchronized.
           45 :pref:-ecdh-curve usage is pointer synchronized.
           45 :pref:-vhost-name usage is pointer synchronized.
           45 :pref:-plugin-dirs usage is pointer synchronized.
           45 :pref:-pvo usage is pointer synchronized.
           45 :pref:-keepalive-timeout
               :tp-int: synchronized.
           45 :pref:-log-filepath usage is pointer synchronized.
           45 :pref:-mounts usage is pointer synchronized.
           45 :pref:-server-string usage is pointer synchronized.
           45 :pref:-pt-serv-buf-size
               :tp-uint: synchronized.
           45 :pref:-max-http-header-data2
               :tp-uint: synchronized.
           45 :pref:-ssl-options-set
               :tp-long: synchronized.
           45 :pref:-ssl-options-clear
               :tp-long: synchronized.
           45 :pref:-ws-ping-pong-internal
               :tp-ush: synchronized.
           45 :pref:-headers usage is pointer synchronized.
           45 :pref:-reject-service-keywords
               usage is pointer synchronized.
           45 :pref:-external-baggage-free-on-destroy
               usage is pointer synchronized.
           45 :pref:-client-ssl-private-key-password
               usage is pointer synchronized.
           45 :pref:-client-ssl-cert-filepath
               usage is pointer synchronized.
           45 :pref:-client-ssl-cert-men
               usage is pointer synchronized.
           45 :pref:-client-ssl-cert-mem-len
               :tp-uint: synchronized.
           45 :pref:-client-ssl-private-key-filepath
               usage is pointer synchronized.
           45 :pref:-client-ssl-ca-filepath
               usage is pointer synchronized.
           45 :pref:-client-ssl-ca-mem usage is pointer synchronized.
           45 :pref:-client-ssl-ca-mem-len
               :tp-uint: synchronized.
           45 :pref:-client-ssl-cipher-list
               usage is pointer synchronized.
           45 :pref:-fops usage is pointer synchronized.
           45 :pref:-simultaneous-ssl-restriction
               :tp-int: synchronized.
           45 :pref:-socks-proxy-address usage is pointer synchronized.
           45 :pref:-socks-proxy-port
               :tp-uint: synchronized.
      *TODO: do the rest of the fields
      *socks_proxy_address
           45 filler usage is pointer occurs 64 times.
       >>END-IF
       >>IF WEBSOCKET-ABI = "1"
           45 :pref:-gid
               :tp-gid: synchronized.
           45 :pref:-uid
               :tp-uid: synchronized.
           45 :pref:-options
               :tp-uint64: synchronized.
           45 :pref:-user usage is pointer synchronized.
           45 :pref:-count-threads
               :tp-uint: synchronized.
           45 :pref:-fd-limit-per-thread
               :tp-uint: synchronized.
           45 :pref:-vhost-name usage is pointer synchronized.
           45 :pref:-external-baggage-free-on-destroy
               usage is pointer synchronized.
           45 :pref:-pt-serv-buf-size
               :tp-uint: synchronized.
           45 :pref:-foreign-loops usage is pointer synchronized.
           45 :pref:-signal-cb usage is pointer synchronized.
           45 :pref:-pcontext usage is pointer synchronized.
           45 :pref:-finalize usage is pointer synchronized.
           45 :pref:-finalize-arg usage is pointer synchronized.
           45 :pref:-listen-accept-role usage is pointer synchronized.
           45 :pref:-listen-accept-protocol
               usage is pointer synchronized.
           45 :pref:-pprotocols usage is pointer synchronized.
           45 :pref:-username usage is pointer synchronized.
           45 :pref:-groupname usage is pointer synchronized.
           45 :pref:-unix-socket-perms usage is pointer synchronized.
           45 :pref:-system-ops usage is pointer synchronized.
           45 :pref:-retry-and-idle-policy
               usage is pointer synchronized.
           45 :pref:-rlimit-nofile usage is binary-long synchronized.
           45 :pref:-fo-listen-queue usage is binary-long synchronized.
           45 :pref:-event-lib-custom usage is pointer synchronized.
           45 :pref:-log-cx usage is pointer synchronized.
           45 filler usage is pointer occurs 2 times.
       >>END-IF
