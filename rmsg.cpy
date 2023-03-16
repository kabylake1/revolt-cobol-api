      *Send message structure
       01  :pref:-msg.
           02 :pref:-nonce pic x(64).
           02 :pref:-content pic x(2000).
           02 :pref:-attachments pic x(128) occurs 128 times.
           02 :pref:-replies occurs 16 times.
               03 :pref:-id pic x(80).
               03 :pref:-mention pic x(8).
           02 :pref:-embeds occurs 10 times.
               03 :pref:-embed-icon-url pic x(80).
               03 :pref:-embed-url pic x(80).
               03 :pref:-embed-title pic x(80).
               03 :pref:-embed-description pic x(80).
               03 :pref:-embed-media pic x(80).
               03 :pref:-embed-colour pic x(80).
           02 :pref:-masquerade.
               03 :pref:-masq-name pic x(80).
               03 :pref:-masq-avatar pic x(80).
               03 :pref:-masq-colour pic x(80).
           02 :pref:-interactions.
               03 :pref:-reactions pic x(80) occurs 16 times.
               03 :pref:-restrict-reactions pic x(8).
