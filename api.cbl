       copy "cabi.cpy".
       replace also ==:max-msg-len:== by 2000.
       replace also ==:rx-bufsize:== by 4096.
      ******************************************************************
       identification division.
       program-id. rv-init.
       environment division.
       input-output section.
       file-control.
           select fd-token assign to "token.txt"
           organization is line sequential.
           select fd-server assign to "server.txt"
           organization is line sequential.
       data division.
       file section.
       fd  fd-token.
       01  fs-token picture x(80).
       fd  fd-server.
       01  fs-server picture x(80).
       working-storage section.
       copy "winf.cpy" replacing ==:pref:== by ==ws==
                       ==:levl:== by ==01==.
       copy "curl.cpy" replacing ==:pref:== by ==ws-==.
       01  ws-text picture x(160).
       01  ws-count picture 9(8).
       01  ws-status :tp-int: synchronized.
       linkage section.
       copy "rcfg.cpy" replacing ==:pref:== by ==ls==
                       ==:levl:== by ==01==.
       procedure division using by reference ls-config
           returning omitted.
      *
           if ls-onrun-pgm is equal to null then
               display "[API] OnRun callback not set!" end-display
               goback
           end-if.
           set ls-root in ls-config to address of ls-config.
      *Read token from token file (if needed)
           if ls-token(1:1) is equal to space then
               open input sharing with all fd-token
               read fd-token into ls-token in ls-config end-read
               close fd-token
           end-if.
      *Read servername from token file (if needed)
           if ls-token(1:1) is equal to space then
               open input sharing with all fd-server
               read fd-server into ls-url in ls-config end-read
               close fd-server
           end-if.
           perform curl-init.
           perform ws-init.
      *Call the callbacks
           if ls-oninit-pgm is not equal to null then
               call ls-oninit-pgm using by reference ls-config end-call
           end-if
           perform forever
      *        call ls-onrun-pgm using by reference ls-config end-call
               call "config-state" using by reference ls-config
                   by value "write" end-call
      *Servicing the websockets
               call "lws-service" using
                   by value ls-ws-ctx
                   by value 1000
                   returning ws-status end-call
               if ws-status less than zero then
                   exit perform
               end-if
           end-perform.
      *Finalize
           perform ws-cleanup.
           perform curl-cleanup.
           goback.
       curl-init.
      *Initialize libCurl
           call "curl-global-init" using by value x'ff' end-call.
           call "curl-easy-init" using by reference ls-curl end-call.
           if ls-curl is equal to null then
               display "[API] Unable to initialize curl" end-display
               goback
           end-if.
      *Setup the slist
           initialize ls-chunks.
      *Session token slist
           initialize ws-text.
           string
               "X-Bot-Token:" delimited by size
               ls-token delimited by space
               into ws-text end-string.
           initialize ws-count.
           inspect ws-text tallying ws-count
               for characters before space.
           add 1 to ws-count giving ws-count end-add.
           move low-value to ws-text(ws-count:1).
           call "curl-slist-append" using by value ls-chunks
               by reference ws-text
               by reference ls-chunks end-call.
           if ls-chunks is equal to null then
               display "[API] Unable to set x-bot-token" end-display
               goback
           end-if.
      *And finally content type
           initialize ws-count.
           unstring "Content-Type:application/json"
               delimited by low-value
               into ws-text
               count in ws-count
           end-unstring.
           add 1 to ws-count giving ws-count end-add.
           move low-value to ws-text(ws-count:1).
           call "curl-slist-append" using by value ls-chunks
               by reference ws-text
               by reference ls-chunks end-call.
           if ls-chunks is equal to null then
               display "[API] Unable to set content-type" end-display
               goback
           end-if.
       curl-cleanup.
           call static "curl-slist-free-all" using
               by value ls-chunks end-call.
           call "curl-easy-cleanup" using by value ls-curl end-call.
           call "curl-global-cleanup" end-call.
       ws-init.
           call static "lws-set-log-level" using by value 255
               by value 0
               returning omitted end-call.
           initialize ws-info.
           display "[API] Querying available protocols" end-display.
           call "get-protocols" using
               by reference ws-protocols in ws-info end-call.
           move 4096 to ws-options in ws-info.
      *Since some day, libwebsockets uses -1 (integer) for
      *saying that "we will not serve any clients, we're a client"
      *instead of the original 0, ???
           move -1 to ws-port in ws-info.
           display "[API] Initializing WebSockets context" end-display.
           call "lws-create-context" using
               by reference ws-info
               by reference ls-ws-ctx in ls-config end-call.
           if ls-ws-ctx is equal to null then
               display "[API] Unable to start WebSockets" end-display
               set return-code to 1
               goback
           end-if.
           display "[API] Finished starting WebSockets" end-display.
       ws-cleanup.
           call "lws-context-destroy" using
               by value ls-ws-ctx in ls-config end-call.
       end program rv-init.
      ******************************************************************
       identification division.
       program-id. rv-poll-ws.
       data division.
       working-storage section.
       copy "curl.cpy" replacing ==:pref:== by ==ws-==.
       01  ws-endpoint picture x(255).
       01  ws-response picture x(:rx-bufsize:).
       01  ws-frame-len :tp-uint: synchronized.
       01  ws-status :tp-uint: synchronized.
       linkage section.
       copy "rcfg.cpy" replacing ==:pref:== by ==ls==
                       ==:levl:== by ==01==.
       procedure division using by reference ls-config
           returning omitted.
      *
           initialize ws-response, ws-endpoint.
           string
               ls-ws-url delimited by space
               "/?format=json" delimited by size
               into ws-endpoint end-string.
      *    call static "curl_ws_recv" using by value ls-ws-ctx
      *        by reference ws-response
      *        by value function length(ws-response)
      *        by value ws-frame-len
      *        by reference ls-ws-frame
      *        returning ws-status end-call.
           display "[API] WebSocket " ws-status end-display.
           goback.
       end program rv-poll-ws.
      ******************************************************************
       identification division.
       program-id. rv-send-msg.
       data division.
       working-storage section.
       01  ws-endpoint picture x(255).
       01  ws-text picture x(:max-msg-len:).
       01  ws-count picture 9(8).
       copy "curl.cpy" replacing ==:pref:== by ==ws-==.
       copy "rmsg.cpy" replacing ==:pref:== by ==ws==
                       ==:levl:== by ==01==.
       01  ws-response picture x(:rx-bufsize:).
       linkage section.
       01  ls-target picture x(26).
       copy "rmsg.cpy" replacing ==:pref:== by ==ls==
                       ==:levl:== by ==01==.
       copy "rcfg.cpy" replacing ==:pref:== by ==ls==
                       ==:levl:== by ==01==.
       procedure division using by reference ls-config
           by value ls-target
           by value ls-msg
           returning omitted.
      *
           initialize ws-response.
      *
           initialize ws-endpoint.
           string
               ls-url delimited by space
               "/channels/" delimited by size
               ls-target delimited by size
               "/messages" delimited by size
               into ws-endpoint end-string.
      *
           initialize ws-text.
           move ls-msg to ws-msg.
           json generate ws-text from ws-msg
               name of ws-msg is omitted
                   ws-content is "content"
                   suppress ws-nonce
               end-json.
           display "[API] JSON: " ws-text end-display.
      *
           initialize ws-count.
           inspect ws-text tallying ws-count
               for characters before space.
           move low-value to ws-text(ws-count:1).
           call "curl-easy-setopt" using by value ls-curl
               by value ws-curlopt-postfields
               by reference ws-text end-call.
           display "[API] JsonFinalText: " ws-text end-display.
      *
           call "http-request" using by reference ls-config
               by content ws-endpoint
               by value "POST"
               by reference ws-response end-call.
           goback.
       end program rv-send-msg.
      ******************************************************************
       identification division.
       program-id. rv-query-last-msg.
       data division.
       working-storage section.
       copy "curl.cpy" replacing ==:pref:== by ==ws-==.
       01  ws-endpoint picture x(255).
       01  ws-response picture x(:rx-bufsize:).
       01  ws-count picture 9(8).
       linkage section.
       copy "rcfg.cpy" replacing ==:pref:== by ==ls==
                       ==:levl:== by ==01==.
       01  ls-target picture x(26).
       copy "rmsg.cpy" replacing ==:pref:== by ==ls==
                       ==:levl:== by ==01==.
       procedure division using by reference ls-config
           by value ls-target
           by reference ls-msg
           returning omitted.
      *
           initialize ws-response.
      *
           initialize ws-endpoint.
           string
               ls-url delimited by space
               "/channels/" delimited by size
               ls-target delimited by size
               "/messages" delimited by size
               into ws-endpoint end-string.
      *
           call "http-request" using by reference ls-config
               by content ws-endpoint
               by value "GET "
               by reference ws-response end-call.
      *
           initialize ls-msg, ws-count.
      *TODO: This is janky and clunky - we have JSON PARSE but GnuCOBOL
      *doesn't support it yet!
           inspect ws-response tallying ws-count
               for characters before initial '"content":'.
           add 1 to ws-count giving ws-count end-add.
           add 10 to ws-count giving ws-count end-add.
      *Skip quote
           add 1 to ws-count giving ws-count end-add.
           move ws-response(ws-count:80) to ls-content.
           goback.
       end program rv-query-last-msg.
      ******************************************************************
       identification division.
       program-id. rv-query-node.
       data division.
       working-storage section.
       copy "curl.cpy" replacing ==:pref:== by ==ws-==.
       01  ws-endpoint picture x(255).
       01  ws-response picture x(:rx-bufsize:).
       linkage section.
       copy "rcfg.cpy" replacing ==:pref:== by ==ls==
                       ==:levl:== by ==01==.
       procedure division using by reference ls-config
           returning omitted.
      *
           initialize ws-response.
      *
           initialize ws-endpoint.
           string
               ls-url delimited by space
               "/" delimited by size
               into ws-endpoint end-string.
      *
           call "http-request" using by reference ls-config
               by content ws-endpoint
               by value "GET "
               by reference ws-response end-call.
           goback.
       end program rv-query-node.
      ******************************************************************
       identification division.
       program-id. http-request.
       data division.
       working-storage section.
       copy "curl.cpy" replacing ==:pref:== by ==ws-==.
       01  ws-count picture 9(8).
       01  ws-write-pgm usage program-pointer.
       01  ws-status :tp-uint: synchronized.
       linkage section.
       copy "rcfg.cpy" replacing ==:pref:== by ==ls==
                       ==:levl:== by ==01==.
       01  ls-endpoint picture x(255).
       01  ls-reqtype picture x(4).
       01  ls-response usage pointer.
       procedure division using by reference ls-config
           by value ls-endpoint
           by value ls-reqtype
           by value ls-response.
      *
           display "[API] " ls-reqtype " at " ls-endpoint end-display.
           initialize ws-count.
           inspect ls-endpoint tallying ws-count
               for characters before space.
           if ws-count is equal to zero then
               goback
           end-if.
           add 1 to ws-count giving ws-count end-add.
           move low-value to ls-endpoint(ws-count:1).
      *    call static "cob_verify_c_str" using by reference ls-endpoint
      *        by value function length(ls-endpoint) end-call.
           display "[API] " ls-endpoint end-display.
           call "curl-easy-setopt" using by value ls-curl
               by value ws-curlopt-url
               by reference ls-endpoint end-call.
      *    call "curl-easy-setopt" using by value ls-curl
      *        by value ws-curlopt-verbose
      *        by value 1 end-call.
           call "curl-easy-setopt" using by value ls-curl
               by value ws-curlopt-use-ssl
               by value x'ff' end-call.
           call "curl-easy-setopt" using by value ls-curl
               by value ws-curlopt-httpheader
               by value ls-chunks end-call.
      *    call "curl-dump-slist" using
      *        by value ls-chunks end-call.
           evaluate ls-reqtype(1:1)
               when 'G'
                  call "curl-easy-setopt" using by value ls-curl
                      by value ws-curlopt-post
                      by value 0 end-call
               when 'P'
                  call "curl-easy-setopt" using by value ls-curl
                      by value ws-curlopt-post
                      by value 1 end-call
           end-evaluate.
           set ws-write-pgm to entry "http-output-fill".
           call "curl-easy-setopt" using by value ls-curl
               by value ws-curlopt-writefunction
               by value ws-write-pgm end-call.
           call "curl-easy-setopt" using by value ls-curl
               by value ws-curlopt-writedata
               by value ls-response end-call.
      *Perform the request
           call "curl-easy-perform" using by value ls-curl
               returning ws-status end-call.
           display "[API] curl call: " ws-status end-display.
           goback.
       end program http-request.
      ******************************************************************
       identification division.
       program-id. http-output-fill.
       environment division.
       input-output section.
       file-control.
           select optional fs-outputs assign to "response.txt"
           organization is line sequential.
       data division.
       file section.
       fd  fs-outputs.
       01  fs-output picture x(:rx-bufsize:).
       working-storage section.
       01  ws-text picture x(:rx-bufsize:).
       01  ws-data picture x(:rx-bufsize:) based.
       01  ws-total :tp-uint: synchronized.
       linkage section.
       01  ls-data usage is pointer synchronized.
       01  ls-size :tp-sizet: synchronized.
       01  ls-size-num redefines ls-size :tp-uint: synchronized.
       01  ls-nmemb :tp-sizet: synchronized.
       01  ls-nmemb-num redefines ls-nmemb :tp-uint: synchronized.
       01  ls-userdata usage is pointer synchronized.
       procedure division using by value ls-data
           by value ls-size
           by value ls-nmemb
           by value ls-userdata.
      *
           initialize ws-text.
      *
           multiply ls-size-num by ls-nmemb-num
               giving ws-total end-multiply.
      *
           display "ws-total " ws-total end-display.
           set address of ws-data to ls-data.
           move ws-data(1:ws-total) to ws-text.
           display "ws-writing " ws-text end-display.
           open extend fs-outputs.
           write fs-output from ws-text end-write.
           close fs-outputs.
      *
           set return-code to ws-total.
      *
           goback.
       end program http-output-fill.
      ******************************************************************
       identification division.
       program-id. ws-callback recursive.
       environment division.
       configuration section.
       special-names.
           call-convention 0 is extern.
       data division.
       working-storage section.
       copy "wccl.cpy" replacing ==:pref:== by ==ws==
                       ==:levl:== by ==01==.
       copy "rcfg.cpy" replacing ==:pref:== by ==ws==
                       ==:levl:== by ==01==.
       01  ws-count picture 9(8).
       01  ws-p-vhost usage is pointer.
       01  ws-p-protocol usage is pointer.
       01  ws-status :tp-int:.
       linkage section.
       01  ls-wsi usage is pointer synchronized.
       01  ls-reason :tp-int: synchronized.
       copy "wsws.cpy" replacing ==:pref:== by ==ls-==.
       01  ls-user usage is pointer synchronized.
       01  ls-in usage is pointer synchronized.
      *TODO: This is a workaround with a bug from GnuCOBOL
      *where linkage elements not listed on the "USING BY" part of
      *the procedure will get murdered
       01  ls-status :tp-int: synchronized.
       01  ls-length :tp-sizet: synchronized.
       procedure division extern using by value ls-wsi
           by value ls-reason
           by value ls-user
           by value ls-in
           by value ls-length.
      *Read the state from the file
           call "config-state" using
               by reference ws-config
               by value "read" end-call.
      *
           display "[API] WebSocket callback called"
               " WSI " ls-wsi
               " Reason " ls-reason
               " User " ls-user
               " In " ls-in
               " Length " ls-length end-display.
           evaluate true
               when ls-callback-client-connection-error
                   perform client-error
               when ls-callback-protocol-init
                   call "ws-connect-client" using
                      by reference ws-config
                      returning ws-status end-call
               when ls-callback-client-writeable
                   perform client-writeable
               when ls-callback-client-established
                   perform client-established
               when ls-callback-client-receive
                   perform client-receive
               when ls-callback-client-receive-pong
                   perform client-receive-pong
               when ls-callback-closed
                   perform client-close
               when ls-callback-closed
                   perform client-close
               when ls-callback-timer
                   perform client-timer
               when ls-callback-user
                   perform client-user
               when other
                   exit 
           end-evaluate.
      *Save back the state into the file
           call "config-state" using
               by reference ws-config
               by value "write" end-call.
           call "lws-callback-http-dummy" using
               by value ls-wsi
               by value ls-reason
               by value ls-user
               by value ls-in
               by value ls-length
               returning ws-status end-call.
           set return-code to ws-status.
           goback.
       client-writeable.
           display "[API] WebSocket writeable" end-display.
       client-established.
           display "[API] WebSocket established" end-display.
           call "lws-set-timer-usecs" using
               by value ls-wsi
               by value 5000000
               returning omitted end-call.
       client-receive.
           display "[API] WebSocket receive" end-display.
       client-error.
           display "[API] Client-Error! <" no advancing end-display.
           call static "cob_print" using by value ls-in end-call.
           display ">" end-display.
           perform client-close.
           stop run returning 1.
       client-close.
           display "[API] Closing WebSocket" end-display.
           set ws-client-wsi in ws-config to null.
           call "lws-get-vhost" using by value ls-wsi
               by reference ws-p-vhost
               returning omitted end-call.
           call "lws-get-protocol" using by value ls-wsi
               by reference ws-p-protocol
               returning omitted end-call.
           call "lws-timed-callback-vh-protocol" using
               by value ws-p-vhost
               by value ws-p-protocol
               by value 1000
               by value 1
               returning omitted end-call.
       client-timer.
           display "[API] Client timer!?" end-display.
           call "lws-callback-on-writable" using by value ls-wsi
               returning omitted end-call.
           call "lws-set-timer-usecs" using by value ls-wsi
               by value 5000000
               returning omitted end-call.
       client-receive-pong.
           display "[API] Callback Received pong!?" end-display.
           stop run returning 1.
       client-user.
           display "[API] Callback USER" end-display.
           call "ws-connect-client" using by reference ws-config
               returning ws-status end-call.
           if ws-status is equal to zero then
               display "[API] Connecting client!" end-display
               call "lws-get-vhost" using by value ls-wsi
                   by reference ws-p-vhost
                   returning omitted end-call
               call "lws-get-protocol" using by value ls-wsi
                   by reference ws-p-protocol
                   returning omitted end-call
               call "lws-timed-callback-vh-protocol" using
                   by value ws-p-vhost
                   by value ws-p-protocol
                   by value 1000
                   by value 1
                   returning omitted end-call
           end-if.
       end program ws-callback.
      ******************************************************************
       identification division.
       program-id. ws-connect-client.
       data division.
       working-storage section.
       copy "wccl.cpy" replacing ==:pref:== by ==ws==
                       ==:levl:== by ==01==.
       01  ws-zurl-path picture x(160).
       01  ws-zws-url picture x(80).
       01  ws-count picture 9(8).
       01  ws-proto-name picture x(80) value "revolt-protocol" & x'00'.
       linkage section.
       copy "rcfg.cpy" replacing ==:pref:== by ==ls==
                       ==:levl:== by ==01==.
       procedure division using by reference ls-config.
      *Read the state from the file
           display "[API] Initializing WebSocket conn." end-display.
           initialize ws-conn.
           move ls-ws-ctx in ls-config to ws-context in ws-conn.
           if ws-context in ws-conn is equal to null then
               display "[API] Null context passed to WebSocket"
               " connection builder" end-display
               set return-code to 1
               goback
           end-if.
      *Nil-terminate the WebSocket URLs
           initialize ws-count, ws-zws-url.
           move ls-ws-url in ls-config to ws-zws-url.
           inspect ws-zws-url tallying ws-count
               for characters before space.
           add 1 to ws-count giving ws-count end-add.
           move low-value to ws-zws-url(ws-count:1).
           set ws-address in ws-conn,
               ws-host in ws-conn,
               ws-origin in ws-conn to address of ws-zws-url.
      *Now libwebsockets will have a pointer to our slash path
      *so we will just keep it alive for as long as the program
      *exists!
           initialize ws-count, ws-zurl-path.
           string
               "/ws?format=json&version=1&token=" delimited by size
               "TOKENTOKEN" delimited by space
               into ws-zurl-path end-string.
           inspect ws-zurl-path tallying ws-count
               for characters before space.
           add 1 to ws-count giving ws-count end-add.
           move low-value to ws-zurl-path(ws-count:1).
           set ws-path in ws-conn to address of ws-zurl-path.
      *Enable LCCSCF_USE_SSL=1
           set ws-ssl-connection in ws-conn to 31.
           set ws-protocol in ws-conn,
               ws-local-protocol in ws-conn to address of ws-proto-name.
           set ws-pwsi to address of ls-client-wsi in ls-config.
           move 443 to ws-port in ws-conn.
      *
           display "[API] <*> Address " ws-zws-url end-display.
           display "[API] <*> Port " ws-port in ws-conn end-display.
           display "[API] <*> Path " ws-zurl-path end-display.
      *
           call "lws-client-connect-via-info" using
               by reference ws-conn
               by reference ls-client-wsi in ls-config end-call.
           if ls-client-wsi is equal to null then
               display "[API] Unable to create client WebSocket"
               end-display
               set return-code to 2
               goback
           end-if.
           set return-code to 0.
           goback.
       end program ws-connect-client.
      ******************************************************************
       identification division.
       program-id. config-state.
       environment division.
       input-output section.
       file-control.
           select optional fd-state assign to disk
           organization is sequential.
       data division.
       file section.
       fd  fd-state.
       copy "rcfg.cpy" replacing ==:pref:== by ==fs==
                       ==:levl:== by ==01==.
       working-storage section.
       linkage section.
       copy "rcfg.cpy" replacing ==:pref:== by ==ls==
                       ==:levl:== by ==01==.
       01  ls-action picture x(16).
       procedure division using by reference ls-config
           by value ls-action.
           display "[API] State begin -> " ls-action(1:1) end-display.
           if ls-action(1:1) is equal to 'w' then
               perform state-write
           else
               if ls-action(1:1) is equal to 'r' then
                   perform state-read
               end-if
           end-if
           display "[API] State finish -> " ls-action(1:1) end-display.
           goback.
       state-write.
           open output fd-state.
           write fs-config from ls-config end-write.
           close fd-state.
       state-read.
           open input sharing with all fd-state.
           read fd-state into ls-config end-read.
           close fd-state.
       end program config-state.
      ******************************************************************
      *Obtain a pointer to the list of protocols
       identification division.
       program-id. nilfy-at-char.
       data division.
       working-storage section.
       01  ws-count picture 9(8) computational-5.
       linkage section.
       01  ls-text picture x(8000).
       01  ls-char picture x.
       procedure division using by reference ls-text
           by value ls-char.
      *
           initialize ws-count.
           inspect ls-text tallying ws-count
               for characters before ls-char.
           add 1 to ws-count giving ws-count end-add.
           move low-value to ls-text(ws-count:1).
           goback.
       end program nilfy-at-char.
      ******************************************************************
      *Obtain a pointer to the list of protocols
       identification division.
       program-id. get-protocols.
       data division.
       working-storage section.
       01  ws-requires-init picture 9 value 1.
       01  ws-proto-name picture x(80) value "revolt-protocol" & x'00'.
       01  ws-protocols occurs 4 times.
           copy "wpns.cpy" replacing ==:pref:== by ==ws==.
       linkage section.
       01  ls-p usage is pointer.
       procedure division using by reference ls-p.
           if ws-requires-init is equal to 1 then
               perform first-time-init
               move 0 to ws-requires-init
           end-if
           set ls-p to address of ws-protocols(1).
           goback.
       first-time-init.
           initialize ws-protocols(1).
           set ws-name(1) to address of ws-proto-name.
           set ws-callback(1) to entry "ws-callback".
           if ws-callback(1) is equal to null then
               display "No suitable callback for " ws-proto-name "found"
               end-display
               move 1 to return-code
               goback
           end-if.
      *
           initialize ws-protocols(2).
           initialize ws-protocols(3).
           initialize ws-protocols(4).
       end program get-protocols.
      ******************************************************************
      *Stub function for testing accurate sizing of elements
       identification division.
       program-id. c-abi-test.
       data division.
       working-storage section.
       linkage section.
       01  ls-uint8 :tp-uint8: synchronized.
       01  ls-uint16 :tp-uint16: synchronized.
       01  ls-uint32 :tp-uint32: synchronized.
       01  ls-uint64 :tp-uint64: synchronized.
       01  ls-sizet :tp-sizet: synchronized.
       01  ls-int :tp-uint: synchronized.
       01  ls-uint :tp-uint: synchronized.
       01  ls-sh :tp-sh: synchronized.
       01  ls-ush :tp-ush: synchronized.
       01  ls-long :tp-long: synchronized.
       01  ls-ulong :tp-ulong: synchronized.
       01  ls-pointer usage is pointer synchronized.
       procedure division using by value ls-uint8
           by value ls-uint16
           by value ls-uint32
           by value ls-uint64
           by value ls-sizet
           by value ls-int
           by value ls-uint
           by value ls-sh
           by value ls-ush
           by value ls-long
           by value ls-ulong
           by value ls-pointer.
      *
           goback.
       end program c-abi-test.
      ******************************************************************


GCobol >>SOURCE FORMAT IS FIXED
      *-----------------------------------------------------------------
      * Authors:   Brian Tiffin, Asger Kjelstrup, Simon Sobisch
      * Date:      19-Oct-2010
      * Purpose:   Hex Dump display
      * Tectonics: cobc -c CBL_OC_DUMP.cob
      *     Usage: export OC_DUMP_EXT=1 for explanatory text on dumps
      *            (memory address and dump length)
      *            export OC_DUMP_EXT=Y for extended explanatory text
      *            (architecture   and endian-order)
      *-----------------------------------------------------------------
       IDENTIFICATION DIVISION.
       PROGRAM-ID. CBL_OC_DUMP.
      *
       ENVIRONMENT      DIVISION.
       CONFIGURATION    SECTION.
      *
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       77  addr                             usage pointer.
       77  addr2addr                        usage pointer.
       77  counter               pic 999999 usage comp-5.
       77  byline                pic 999    usage comp-5.
       77  offset                pic 999999.
       01  some                  pic 999    usage comp-5.
           88 some-is-printable-iso88591
              values 32 thru 126, 160 thru 255.
           88 some-is-printable-ebcdic
              values 64, 65, 74 thru 80, 90 thru 97,
                     106 thru 111, 121 thru 127, 129 thru 137, 143,
                     145 thru 153, 159, 161 thru 169, 176,
                     186 thru 188, 192 thru 201, 208 thru 217, 224,
                     226 thru 233, 240 thru 249.
       77  high-var              pic 99     usage comp-5.
       77  low-var               pic 99     usage comp-5.
      *
       01  char-set              pic x(06).
           88 is-ascii           value 'ASCII'.
           88 is-ebdic           value 'EBCDIC'.
           88 is-unknown         value '?'.
       01  architecture          pic x(06).
           88 is-32-bit          value '32-bit'.
           88 is-64-bit          value '64-bit'.
       01  endian-order          pic x(10).
           88 is-big-endian-no   value 'Little-Big'.
           88 is-big-endian-yes  value 'Big-Little'.
      *
       77  hex-line              pic x(48).
       77  hex-line-pointer      pic 9(02) value 1.
      *
       77  show                  pic x(16).
       77  dots                  pic x value '.'.
       77  dump-dots             pic x.
      *
       77  hex-digit             pic x(16)  value '0123456789abcdef'.
       01  extended-infos        pic x.
           88 show-extended-infos      values '1', '2', 'Y', 'y'.
           88 show-very-extended-infos values '2', 'Y', 'y'.
      *
       77  len                   pic 999999 usage comp-5.
       77  len-display           pic 999999.
      *
       LINKAGE SECTION.
       01  buffer                pic x       any length.
       77  byte                  pic x.
      *-----------------------------------------------------------------
       PROCEDURE DIVISION USING buffer.
      *
      *MAIN SECTION.
      *00.
           perform starting-address
      *
           perform varying counter from 0 by 16
                   until   counter  >=   len
              move counter to offset
              move spaces  to hex-line, show
              move '-'     to hex-line (24:01)
              move 1       to hex-line-pointer
              perform varying byline from 1 by 1
                      until   byline  >  16
                 if (counter + byline) > len
                    if byline < 9
                       move space to hex-line (24:01)
                    end-if
                    inspect show (byline:) replacing all spaces by dots
                    exit perform
                 else
                    move buffer (counter + byline : 1) to byte
                    perform calc-hex-value
                    if ((some-is-printable-iso88591 and is-ascii) or
                        (some-is-printable-ebcdic   and is-ebdic)   )
                       move byte to show (byline:1)
                    else
                       move dots to show (byline:1)
                    end-if
                 end-if
              end-perform
              display offset '  ' hex-line '  ' show
                      upon SYSERR
              end-display
           end-perform
           display ' '
                   upon SYSERR
           end-display
      *
           exit program.
      *-----------------------------------------------------------------
       CALC-HEX-VALUE SECTION.
      *00.
           subtract 1 from function ord(byte) giving some
           end-subtract
           divide   some by 16 giving high-var remainder low-var
           end-divide
           string hex-digit (high-var + 1:1)
                  hex-digit (low-var  + 1:1)
                  space
                  delimited by size
                  into hex-line
                  with pointer hex-line-pointer
           end-string
      *
           exit section.
      *-----------------------------------------------------------------
       STARTING-ADDRESS SECTION.
      *00.
      * Get the length of the transmitted buffer
           CALL 'C$PARAMSIZE' USING 1
              GIVING len
           END-CALL
      * If wanted, change the dots to something different than points
           accept dump-dots from environment 'OC_DUMP_DOTS'
             not on exception
                 move dump-dots to dots
           end-accept
      *
           perform TEST-ASCII
           perform TEST-ENDIAN
           set addr      to address of buffer
           set addr2addr to address of addr
      *
           if len > 0
      * To show hex-address, reverse if Big-Little Endian
              if is-big-endian-yes
                 set addr2addr up   by LENGTH OF addr
                 set addr2addr down by 1
              end-if
              move 1 to hex-line-pointer
              perform varying byline from 1 by 1
                      until byline > LENGTH OF addr
                 set address of byte to addr2addr
                 perform calc-hex-value
                 if is-big-endian-yes
                    set addr2addr down by 1
                 else
                    set addr2addr up   by 1
                 end-if
              end-perform
           end-if
      *
      * Get and display characteristics and headline
           accept extended-infos from environment 'OC_DUMP_EXT'
           end-accept
           if show-extended-infos
              display ' '
                      upon SYSERR
              end-display
              if len > 0
                 display 'Dump of memory beginning at Hex-address: '
                          hex-line (1 : 3 * (byline - 1) )
                          upon SYSERR
                 end-display
              end-if
              move len to len-display
              display 'Length of memory dump is: ' len-display
                       upon SYSERR
              end-display
              if show-very-extended-infos
                 perform TEST-64bit
                 display 'Program runs in '
                         architecture ' architecture. '
                         'Char-set is '
                         function trim (char-set) '.'
                         upon SYSERR
                 end-display
                 display 'Byte order is ' endian-order
                         ' endian.'
                         upon SYSERR
                 end-display
              end-if
           end-if
      *
      * Do we have anything to dump?
           if len > 0
      * Ensure that the passed size is not too big
              if len > 999998
                 move 999998 to len, len-display
                 display 'Warning, only the first '
                         len-display  ' Bytes are shown!'
                         upon SYSERR
                 end-display
              end-if
              display ' '
                      upon SYSERR
              end-display
              display 'Offset  '
                      'HEX-- -- -- -5 -- -- -- -- 10 '
                      '-- -- -- -- 15 -- '
                      '  '
                      'CHARS----1----5-'
                      upon SYSERR
              end-display
           else
              display ' '
                      upon SYSERR
              end-display
              display 'Nothing to dump.'
                      upon SYSERR
              end-display
           end-if
      *
           exit section.
      *-----------------------------------------------------------------
       TEST-ASCII SECTION.
      *Function: Discover if running Ascii or Ebcdic
      *00.
           evaluate space
              when x'20'
                 set  is-ascii   to true
              when x'40'
                 set  is-ebdic   to true
              when other
                 set  is-unknown to true
           end-evaluate
      *
           exit section.
      *-----------------------------------------------------------------
       TEST-64BIT SECTION.
      *Function: Discover if running 32/64 bit
      *00.
      *    Longer pointers in 64-bit architecture
           if function length (addr) <= 4
              set  is-32-bit to true
           else
              set  is-64-bit to true
           end-if
      *
           exit section.
      *-----------------------------------------------------------------
       TEST-ENDIAN SECTION.
      *00.
      *    Number-bytes are shuffled in Big-Little endian
           move 128 to byline
           set  address of byte to address of byline
           if function ord(byte) > 0
              set  is-big-endian-yes to true
           else
              set  is-big-endian-no  to true
           end-if
      *
           exit section.
      *----------------------------------------------------------------*
       end program CBL_OC_DUMP.
