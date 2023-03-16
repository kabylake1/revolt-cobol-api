      ******************************************************************
       identification division.
       program-id. rv-init.
       data division.
       working-storage section.
       copy "curl.cpy" replacing ==:pref:== by ==ws-==.
       01  ws-text pic x(160).
       01  ws-count pic 9(8).
       linkage section.
       copy "rcfg.cpy" replacing ==:pref:== by ==ls==.
       procedure division using by value ls-config
           returning omitted.
           if ls-onrun-pgm is equal to null then
               display "[API] OnRun callback not set!" end-display
               goback
           end-if.
           call static "curl_global_init" using by value x'ff' end-call.
           call static "curl_easy_init" returning ls-curl end-call.
           if ls-curl is equal to null then
               display "[API] Unable to initialize curl" end-display
               goback
           end-if.
      *Setup the slist
           initialize ls-chunks.
      *Session token slist
           string
               "X-Bot-Token: " delimited by size
               ls-token(1:80) delimited by space
               into ws-text end-string.
           initialize ws-count.
           inspect ws-text
               tallying ws-count
               for characters before low-value.
           add 1 to ws-count giving ws-count end-add.
           move low-value to ws-text(ws-count:1).
           call static "curl_slist_append" using by value ls-chunks
               by reference ws-text
               returning ls-chunks end-call.
           if ls-chunks is equal to null then
               display "[API] Unable to set x-bot-token" end-display
               goback
           end-if.
      *And finally content type
           initialize ws-count.
           unstring
               "Content-Type: application/json"
               delimited by low-value
               into ws-text
               count in ws-count
           end-unstring.
           add 1 to ws-count giving ws-count end-add.
           move low-value to ws-text(ws-count:1).
           call static "curl_slist_append" using by value ls-chunks
               by reference ws-text
               returning ls-chunks end-call.
           if ls-chunks is equal to null then
               display "[API] Unable to set content-type" end-display
               goback
           end-if.
      *Call the callbacks
           if ls-oninit-pgm is not equal to null then
               call ls-oninit-pgm using by content ls-config end-call
           end-if
           perform forever
               call ls-onrun-pgm using by content ls-config end-call
           end-perform.
      *
           call static "curl_slist_free_all" using
               by value ls-chunks end-call.
           call static "curl_easy_cleanup" using
               by value ls-curl end-call.
           call static "curl_global_cleanup" end-call.
           goback.
       end program rv-init.
      ******************************************************************
       identification division.
       program-id. rv-send-msg.
       data division.
       working-storage section.
       01  ws-endpoint pic x(255).
       01  ws-text pic x(2000).
       01  ws-count pic 9(8).
       copy "curl.cpy" replacing ==:pref:== by ==ws-==.
       copy "rmsg.cpy" replacing ==:pref:== by ==ws==.
       01  ws-response pic x(4096).
       linkage section.
       01  ls-target pic x(26).
       copy "rmsg.cpy" replacing ==:pref:== by ==ls==.
       copy "rcfg.cpy" replacing ==:pref:== by ==ls==.
       procedure division using by value ls-config
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
               for characters before low-value.
           move low-value to ws-text(ws-count:1).
           call static "curl_easy_setopt" using by value ls-curl
               by value ws-curlopt-postfields
               by reference ws-text end-call.
           display "[API] JsonFinalText: " ws-text end-display.
      *
           call static "http-request" using by content ls-config
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
       01  ws-endpoint pic x(255).
       01  ws-response pic x(4096).
       01  ws-count pic 9(8).
       linkage section.
       copy "rcfg.cpy" replacing ==:pref:== by ==ls==.
       01  ls-target pic x(26).
       copy "rmsg.cpy" replacing ==:pref:== by ==ls==.
       procedure division using by value ls-config
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
           call static "http-request" using by content ls-config
               by content ws-endpoint
               by value "GET "
               by reference ws-response end-call.
      *
           initialize ls-msg, ws-count.
      *TODO: This is janky and clunky - we have JSON PARSE but GnuCOBOL
      *doesn't support it yet!
           inspect ws-response
               tallying ws-count
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
       01  ws-endpoint pic x(255).
       01  ws-response pic x(4096).
       linkage section.
       copy "rcfg.cpy" replacing ==:pref:== by ==ls==.
       procedure division using by value ls-config
           returning omitted.
      *
           initialize ws-response.
      *
           initialize ws-endpoint.
           string
               ls-url(1:80) delimited by space
               "/" delimited by size
               into ws-endpoint end-string.
      *
           call static "http-request" using by content ls-config
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
       01  ws-count pic 9(8).
       01  ws-write-pgm usage program-pointer.
       01  ws-res usage binary-short.
       linkage section.
       copy "rcfg.cpy" replacing ==:pref:== by ==ls==.
       01  ls-endpoint pic x(255).
       01  ls-reqtype pic x(4).
       01  ls-response usage pointer.
       procedure division using by value ls-config
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
           call static "curl_easy_setopt" using by value ls-curl
               by value ws-curlopt-url
               by reference ls-endpoint end-call.
      *    call static "curl_easy_setopt" using by value ls-curl
      *        by value ws-curlopt-verbose
      *        by reference 1 end-call.
           call static "curl_easy_setopt" using by value ls-curl
               by value ws-curlopt-use-ssl
               by reference x'ff' end-call.
           call static "curl_easy_setopt" using by value ls-curl
               by value ws-curlopt-httpheader
               by value ls-chunks end-call.
      *    call static "curl-dump-slist" using
      *        by value ls-chunks end-call.
           evaluate ls-reqtype(1:1)
               when 'G'
                  call static "curl_easy_setopt" using by value ls-curl
                      by value ws-curlopt-post
                      by value 0 end-call
               when 'P'
                  call static "curl_easy_setopt" using by value ls-curl
                      by value ws-curlopt-post
                      by value 1 end-call
           end-evaluate.
           call static "cob_output_refill" end-call.
      *    set ws-write-pgm to entry "http-output-fill".
           set ws-write-pgm to entry "cob_output_fill_glue".
           call static "curl_easy_setopt" using by value ls-curl
               by value ws-curlopt-writefunction
               by value ws-write-pgm end-call.
           call static "curl_easy_setopt" using by value ls-curl
               by value ws-curlopt-writedata
               by value ls-response end-call.
      *Perform the request
           call static "curl_easy_perform" using by value ls-curl
               returning ws-res end-call.
           display "[API] curl call: " ws-res end-display.
           goback.
       end program http-request.
      ******************************************************************
       identification division.
       program-id. curl-dump-slist recursive.
       data division.
       working-storage section.
       01  ws-slist based.
           02 ws-data usage is pointer synchronized.
           02 ws-next usage is pointer synchronized.
       01  ws-text pic x(80) based.
       01  i pic 9(4) comp.
       linkage section.
       01  ls-slist usage is pointer.
       procedure division using by value ls-slist.
           if ls-slist is equal to null then
               display "end-of-slist" end-display
               goback
           end-if.
           set address of ws-slist to ls-slist.
           set address of ws-text to ws-data.
           display ls-slist " -> " with no advancing end-display.
           perform varying i from 1 by 1
               until i is greater than function length(ws-text)
               if ws-text(i:1) is equal to low-value
                   exit perform
               end-if
               display ws-text(i:1) with no advancing end-display
           end-perform.
           display " -> " ws-next end-display.
           call static "curl-dump-slist" using
               by value ws-next end-call.
           goback.
       end program curl-dump-slist.
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
       01  fs-output pic x(4096).
       working-storage section.
       01  ws-text pic x(4096).
       01  ws-data pic x(4096) based.
       linkage section.
       01  ls-data usage is pointer.
       01  ls-size usage is binary-long.
       01  ls-nmemb usage is binary-long.
       01  ls-userdata usage is pointer.
       01  ls-total usage is binary-long.
       procedure division using by value ls-data
           by value ls-size
           by value ls-nmemb
           by value ls-userdata
           returning ls-total.
      *
           initialize ws-text.
           multiply ls-size by ls-nmemb giving ls-total end-multiply.
           display "TotalSize " ls-total end-display.
           set address of ws-data to ls-data.
           move ws-data(1:ls-total) to ws-text.
           display "writing " ws-text end-display.
           open extend fs-outputs.
           write fs-output from ws-text end-write.
           close fs-outputs.
           goback.
       end program http-output-fill.
