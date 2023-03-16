# COBOL bindings for Revolt API

Requires GnuCOBOL and cURL to properly function.

## Introduction
Create a file named `token.txt` and paste your token there.

## Example
Here is a small bot which will print "hello world!" every 5 seconds
to an specific channel id.
```cobol
      ******************************************************************
      *> Main entry point for application
       identification division.
       program-id. rv-test-main.
       data division.
       working-storage section.
       copy "rcfg.cpy" replacing ==:pref:== by ==ws==.
       procedure division.
           *> Important to initialize configuration!
           initialize ws-config.
           *> Set the server we're API'ing at
           move "https://api.revolt.chat" to ws-url.
           set ws-onrun-pgm to entry "rv-onrun".
           *> If we do not fill out "ws-token" - then the library
           *> will do it for us - by reading from a file called
           *> "token.txt" - make sure it exists!
           *>
           *> This is the recommended way of doing things however
           *> as embedding tokens directly into the source code of
           *> a bot isn't a good idea!
           call "rv-init" using by content ws-config end-call.
           goback.
       end program rv-test-main.
      ******************************************************************
      *> Function called on every "running step" of the querying loop
       identification division.
       program-id. rv-onrun.
       data division.
       working-storage section.
       copy "rmsg.cpy" replacing ==:pref:== by ==ws==.
       linkage section.
       copy "rcfg.cpy" replacing ==:pref:== by ==ls==.
       procedure division using by value ls-config.
           initialize ws-msg. *> Initialize all to zero
           move "Hello world!" to ws-content in ws-msg.
           *> Function call to send a message - notice how we're sending
           *> a "ws-msg" which we defined from the "rmsg.cpy" copybook!
           call static "rv-send-msg" using by content ls-config
               *> Important to fill this out with a correct channel id!
               by value "Channel-id-to-send-message-at"
               by content ws-msg end-call.
           *> Just send at an interval of 5 seconds
           call "C$SLEEP" using by content "5" end-call.
           goback.
       end program rv-onrun.
```
