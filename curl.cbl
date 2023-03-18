       copy "cabi.cpy".
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
           call "curl-dump-slist" using
               by value ws-next end-call.
           goback.
       end program curl-dump-slist.
      ******************************************************************
       identification division.
       program-id. curl-easy-setopt.
       data division.
       working-storage section.
       01  ws-status :tp-int:.
       linkage section.
       01  ls-curl usage is pointer.
       01  ls-pointer usage is pointer.
       procedure division using by value ls-curl
           by value ls-pointer.
      *
           call static "curl_easy_setopt" using by value ls-curl
               by value ls-pointer
               returning ws-status end-call.
           set return-code to ws-status.
           goback.
       end program curl-easy-setopt.
      ******************************************************************
       identification division.
       program-id. curl-easy-perform.
       data division.
       working-storage section.
       01  ws-status :tp-int:.
       linkage section.
       01  ls-curl usage is pointer.
       procedure division using by value ls-curl.
      *
           call static "curl_easy_perform" using by value ls-curl
               returning ws-status end-call.
           set return-code to ws-status.
           goback.
       end program curl-easy-perform.
      ******************************************************************
       identification division.
       program-id. curl-slist-append.
       data division.
       working-storage section.
       linkage section.
       01  ls-chunks usage is pointer.
       01  ls-data usage is pointer.
       01  ls-return usage is pointer.
       procedure division using by value ls-chunks
           by value ls-data
           by reference ls-return.
      *
           call static "curl_slist_append" using by value ls-chunks
               by reference ls-data
               returning ls-return end-call.
           goback.
       end program curl-slist-append.
      ******************************************************************
       identification division.
       program-id. curl-slist-free-all.
       data division.
       working-storage section.
       01  ws-status :tp-int:.
       linkage section.
       01  ls-chunks usage is pointer.
       procedure division using by value ls-chunks.
      *
           call static "curl_slist_free_all" using by value ls-chunks
               returning ws-status end-call.
           set return-code to ws-status.
           goback.
       end program curl-slist-free-all.
      ******************************************************************
       identification division.
       program-id. curl-easy-cleanup.
       data division.
       working-storage section.
       01  ws-status :tp-int:.
       linkage section.
       01  ls-curl usage is pointer.
       procedure division using by value ls-curl.
      *
           call static "curl_easy_cleanup" using by value ls-curl
               returning ws-status end-call.
           set return-code to ws-status.
           goback.
       end program curl-easy-cleanup.
      ******************************************************************
       identification division.
       program-id. curl-global-init.
       data division.
       working-storage section.
       01  ws-status :tp-int:.
       linkage section.
       01  ls-flags :tp-int:.
       procedure division using by value ls-flags.
      *
           call static "curl_global_init" using by value ls-flags
               returning ws-status end-call.
           set return-code to ws-status.
           goback.
       end program curl-global-init.
      ******************************************************************
       identification division.
       program-id. curl-global-cleanup.
       data division.
       working-storage section.
       01  ws-status :tp-int:.
       linkage section.
       procedure division.
      *
           call static "curl_global_cleanup"
               returning ws-status end-call.
           set return-code to ws-status.
           goback.
       end program curl-global-cleanup.
      ******************************************************************
       identification division.
       program-id. curl-easy-init.
       data division.
       working-storage section.
       linkage section.
       01  ls-return usage is pointer.
       procedure division using by reference ls-return.
      *
           call static "curl_easy_init"
               returning ls-return end-call.
           goback.
       end program curl-easy-init.
      ******************************************************************
