      ******************************************************************
      * Revolt Main
      ******************************************************************
       identification division.
       program-id. rv-test-main.
       data division.
       working-storage section.
       copy "rcfg.cpy" replacing ==:pref:== by ==ws==.
       procedure division.
           initialize ws-config.
           move "https://api.revolt.chat" to ws-url.
           set ws-onrun-pgm to entry "rv-onrun".
           call "rv-init" using by content ws-config end-call.
           goback.
       end program rv-test-main.
      ******************************************************************
       identification division.
       program-id. rv-onrun.
       data division.
       working-storage section.
       copy "rmsg.cpy" replacing ==:pref:== by ==ws==.
       01  ws-help-msg pic x(160) value "What?! Please use one of the "
           & "following""commands: "
           & "&P - Perform a ping! " 
           & "This bot is a COBOL demostration :-) ".
       linkage section.
       copy "rcfg.cpy" replacing ==:pref:== by ==ls==.
       procedure division using by value ls-config.
           display "Running!" end-display.   
      *    call static "rv-query-node" using
      *        by content ls-config end-call.
           initialize ws-msg.
           call static "rv-query-last-msg" using by content ls-config
               by value "PutChannelIdHere"
               by reference ws-msg end-call.
           display "Content-Is: " ws-content(1:80) end-display.
           if ws-content(1:1) is equal to '&' then
               evaluate ws-content(2:1)
                   when 'P' perform cmd-pong
                   when other perform cmd-idk
               end-evaluate
           end-if.
           call "C$SLEEP" using by content "4" end-call.
      *
           goback.
       cmd-pong.
           initialize ws-msg.
           move "Pong from COBOL!" to ws-content in ws-msg.
           call static "rv-send-msg" using by content ls-config
               by value "PutChannelIdHere"
               by content ws-msg end-call.
       cmd-idk.
           initialize ws-msg.
           move ws-help-msg to ws-content in ws-msg.
           call static "rv-send-msg" using by content ls-config
               by value "PutChannelIdHere"
               by content ws-msg end-call.
       end program rv-onrun.
