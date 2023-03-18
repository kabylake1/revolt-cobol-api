      *Send message structure
       :levl: :pref:-msg.
           45 :pref:-nonce pic x(64).
           45 :pref:-content pic x(2000).
           45 :pref:-attachments pic x(128) occurs 128 times.
           45 :pref:-replies occurs 16 times.
               46 :pref:-id pic x(80).
               46 :pref:-mention pic x(8).
           45 :pref:-embeds occurs 10 times.
               46 :pref:-embed-icon-url pic x(80).
               46 :pref:-embed-url pic x(80).
               46 :pref:-embed-title pic x(80).
               46 :pref:-embed-description pic x(80).
               46 :pref:-embed-media pic x(80).
               46 :pref:-embed-colour pic x(80).
           45 :pref:-masquerade.
               46 :pref:-masq-name pic x(80).
               46 :pref:-masq-avatar pic x(80).
               46 :pref:-masq-colour pic x(80).
           45 :pref:-interactions.
               46 :pref:-reactions pic x(80) occurs 16 times.
               46 :pref:-restrict-reactions pic x(8).
