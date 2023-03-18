# COBOL bindings for Revolt API

## Introduction
Create a file named `token.txt` and paste your token there.

Pre-requisites:
* GnuCOBOL
* WebSockets
* curl

On Debian based systems it's easy as:
```sh
sudo apt install libwebsockets-dev libcurl4-dev gnucobol
```

## Example
Here is a small bot which will print "hello world!" every 5 seconds
to an specific channel id.
```cobol
      *> Main entry point for application
       identification division.
       program-id. rv-test-main.
       data division.
       working-storage section.
       copy "rcfg.cpy" replacing ==:pref:== by ==ws==
                       ==:levl:== by ==01==.
       procedure division.
           initialize ws-config.
           set ws-onrun-pgm to entry "rv-onrun".
           call "rv-init" using by content ws-config end-call.
           goback.
       end program rv-test-main.
      *> Function called on every "running step" of the querying loop
       identification division.
       program-id. rv-onrun.
       data division.
       working-storage section.
       copy "rmsg.cpy" replacing ==:pref:== by ==ws==
                       ==:levl:== by ==01==.
       linkage section.
       copy "rcfg.cpy" replacing ==:pref:== by ==ls==
                       ==:levl:== by ==01==.
       procedure division using by reference ls-config.
           initialize ws-msg.
           move "Hello world!" to ws-content in ws-msg.
           *> Function call to send a message - notice how we're sending
           *> a "ws-msg" which we defined from the "rmsg.cpy" copybook!
           call static "rv-send-msg" using by reference ls-config
               *> Important to fill this out with a correct channel id!
               by value "Channel-id-to-send-message-at"
               by reference ws-msg end-call.
           *> Just send at an interval of 5 seconds
           call "C$SLEEP" using by content "5" end-call.
           goback.
       end program rv-onrun.
```
If we do not fill out "ws-token" - then the library will do it for us - by reading from a file called "token.txt" - make sure it exists beforehand or the program *will* crash. This is the recommended way of doing things however as embedding tokens directly into the source code of a bot isn't a good idea. Additionaly the instance URL is fetched from "server.txt" file automatically.

## Resources
Noteworthy resources to aid in development:
* [Revolt API Reference](https://developers.revolt.chat/api/)
* [GnuCOBOL FAQ](https://gnucobol.sourceforge.io/faq/index.html)
