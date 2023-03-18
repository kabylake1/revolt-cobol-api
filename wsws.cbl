       copy "cabi.cpy".
      ******************************************************************
       identification division.
       program-id. lws-get-vhost.
       data division.
       working-storage section.
       01  ws-wsi usage is pointer synchronized.
       linkage section.
       01  ls-wsi usage is pointer.
       01  ls-return usage is pointer.
       procedure division using by value ls-wsi
           by reference ls-return
           returning omitted.
      *
           set ws-wsi to ls-wsi.
           call static "lws_get_vhost" using by value ws-wsi
               returning ls-return end-call.
           goback.
       end program lws-get-vhost.
      ******************************************************************
       identification division.
       program-id. lws-get-protocol.
       data division.
       working-storage section.
       01  ws-wsi usage is pointer synchronized.
       linkage section.
       01  ls-wsi usage is pointer.
       01  ls-return usage is pointer.
       procedure division using by value ls-wsi
           by reference ls-return
           returning omitted.
      *
           set ws-wsi to ls-wsi.
           call static "lws_get_protocol" using by value ws-wsi
               returning ls-return end-call.
           goback.
       end program lws-get-protocol.
      ******************************************************************
       identification division.
       program-id. lws-timed-callback-vh-protocol.
       data division.
       working-storage section.
       01  ws-status :tp-int:.
       linkage section.
       01  ls-vhost usage is pointer.
       01  ls-protocol usage is pointer.
       01  ls-reason :tp-int:.
       01  ls-timer :tp-int:.
       procedure division using by value ls-vhost
           by value ls-protocol
           by value ls-reason
           by value ls-timer.
      *
           call static "lws_timed_callback_vh_protocol" using
               by value ls-vhost
               by value ls-protocol
               by value ls-reason
               by value ls-timer
               returning ws-status end-call.
           set return-code to ws-status.
           goback.
       end program lws-timed-callback-vh-protocol.
      ******************************************************************
       identification division.
       program-id. lws-callback-on-writable.
       data division.
       working-storage section.
       01  ws-status :tp-int:.
       linkage section.
       01  ls-wsi usage is pointer.
       procedure division using by value ls-wsi.
      *
           call static "lws_callback_on_writable" using by value ls-wsi
               returning ws-status end-call.
           set return-code to ws-status.
           goback.
       end program lws-callback-on-writable.
      ******************************************************************
       identification division.
       program-id. lws-set-timer-usecs.
       data division.
       working-storage section.
       01  ws-status :tp-int:.
       linkage section.
       01  ls-wsi usage is pointer.
       01  ls-usecs :tp-int:.
       procedure division using by value ls-wsi
           by value ls-usecs.
      *
           call static "lws_set_timer_usecs" using by value ls-wsi
               by value ls-usecs
               returning ws-status end-call.
           set return-code to ws-status.
           goback.
       end program lws-set-timer-usecs.
      ******************************************************************
       identification division.
       program-id. lws-callback-http-dummy.
       data division.
       working-storage section.
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
       procedure division using by value ls-wsi
           by value ls-reason
           by value ls-user
           by value ls-in
           by value ls-length.
      *
           call static "lws_callback_http_dummy" using by value ls-wsi
               by value ls-reason
               by value ls-user
               by value ls-in
               by value ls-length
               returning ws-status end-call.
           set return-code to ws-status.
           goback.
       end program lws-callback-http-dummy.
      ******************************************************************
       identification division.
       program-id. lws-service.
       data division.
       working-storage section.
       01  ws-status :tp-int:.
       linkage section.
       01  ls-wsi usage is pointer.
       01  ls-usecs :tp-int:.
       procedure division using by value ls-wsi
           by value ls-usecs.
      *
           call static "lws_service" using by value ls-wsi
               by value ls-usecs
               returning ws-status end-call.
           set return-code to ws-status.
           goback.
       end program lws-service.
      ******************************************************************
       identification division.
       program-id. lws-context-destroy.
       data division.
       working-storage section.
       01  ws-status :tp-int:.
       linkage section.
       01  ls-ws-ctx usage is pointer.
       procedure division using by value ls-ws-ctx.
      *
           call static "lws_context_destroy" using by value ls-ws-ctx
               returning ws-status end-call.
           set return-code to ws-status.
           goback.
       end program lws-context-destroy.
      ******************************************************************
       identification division.
       program-id. lws-create-context.
       data division.
       working-storage section.
       01  ws-pointer usage is pointer.
       linkage section.
       01  ls-info usage is pointer.
       01  ls-return usage is pointer.
       procedure division using by value ls-info
           by reference ls-return.
      *
           call static "lws_create_context" using by value ls-info
               returning ls-return end-call.
           goback.
       end program lws-create-context.
      ******************************************************************
       identification division.
       program-id. lws-canonical-hostname.
       data division.
       working-storage section.
       01  ws-pointer usage is pointer.
       linkage section.
       01  ls-ws-ctx usage is pointer.
       01  ls-return usage is pointer.
       procedure division using by value ls-ws-ctx
           by reference ls-return.
      *
           call static "lws_canonical_hostname" using
               by value ls-ws-ctx
               returning ls-return end-call.
           goback.
       end program lws-canonical-hostname.
      ******************************************************************
       identification division.
       program-id. lws-client-connect-via-info.
       data division.
       working-storage section.
       01  ws-pointer usage is pointer.
       linkage section.
       01  ls-conn usage is pointer.
       01  ls-return usage is pointer.
       procedure division using by value ls-conn
           by reference ls-return.
      *
           call static "lws_client_connect_via_info" using
               by value ls-conn
               returning ls-return end-call.
           goback.
       end program lws-client-connect-via-info.
      ******************************************************************
       identification division.
       program-id. lws-set-log-level.
       data division.
       working-storage section.
       01  ws-status :tp-int:.
       linkage section.
       01  ls-level :tp-int:.
       01  ls-pointer usage is pointer.
       procedure division using by value ls-level
           by value ls-pointer.
      *
           call static "lws_set_log_level" using by value ls-level
               by value ls-pointer
               returning ws-status end-call.
           set return-code to ws-status.
           goback.
       end program lws-set-log-level.
      ******************************************************************

