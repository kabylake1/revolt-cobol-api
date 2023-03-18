      ******************************************************************
      * Revolt Main
      ******************************************************************
       identification division.
       program-id. rv-test-main.
       data division.
       working-storage section.
       copy "rcfg.cpy" replacing ==:pref:== by ==ws==
                       ==:levl:== by ==01==.
       procedure division.
           initialize ws-config.
           move "ws.revolt.chat" to ws-ws-url.
           set ws-onrun-pgm to entry "rv-onrun".
           call "rv-init" using by reference ws-config end-call.
           goback.
       end program rv-test-main.
      ******************************************************************
       identification division.
       program-id. rv-onrun.
       data division.
       working-storage section.
       copy "rmsg.cpy" replacing ==:pref:== by ==ws==
                       ==:levl:== by ==01==.
       01  ws-help-msg pic x(160) value "What?! Please use one of the "
           & "following""commands: "
           & "&P - Perform a ping! " 
           & "This bot is a COBOL demostration :-) ".
       linkage section.
       copy "rcfg.cpy" replacing ==:pref:== by ==ls==
                       ==:levl:== by ==01==.
       procedure division using by reference ls-config.
      *    call static "rv-query-node" using
      *        by reference ls-config end-call.
           initialize ws-msg.
      *    call static "rv-query-last-msg" using by reference ls-config
      *        by reference ws-msg end-call.
           display "Content-Is: " ws-content(1:25) end-display.
           if ws-content is equal to "!pong" then
               perform cmd-pong
           else
               perform cmd-idk
           end-if.
           goback.
       cmd-pong.
           initialize ws-msg.
           move "Pong from COBOL!" to ws-content in ws-msg.
           call static "rv-send-msg" using by reference ls-config
               by value "PutChannelIdHere"
               by content ws-msg end-call.
       cmd-idk.
           initialize ws-msg.
           move ws-help-msg to ws-content in ws-msg.
           call static "rv-send-msg" using by reference ls-config
               by value "PutChannelIdHere"
               by content ws-msg end-call.
       end program rv-onrun.
