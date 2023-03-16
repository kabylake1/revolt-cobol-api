      *Server query structure
       01 :pref:-query-node.
           02 :pref:-revolt pic x(80).
           02 :pref:-features.
               03 :pref:-captcha.
                   04 :pref:-captcha-enabled pic x.
                   04 :pref:-captcha-key pic x(80).
               03 :pref:-email pic x.
               03 :pref:-invite-only pic x.
               03 :pref:-autumn.
                   04 :pref:-autumn-enabled pic x.
                   04 :pref:-autumn-url pic x(80).
               03 :pref:-january.
                   04 :pref:-january-enabled pic x.
                   04 :pref:-january-url pic x(80).
               03 :pref:-voso.
                   04 :pref:-voso-enabled pic x.
                   04 :pref:-voso-url pic x(80).
                   04 :pref:-voso-ws pic x(80).
               03 :pref:-ws pic x(80).
               03 :pref:-app pic x(80).
               03 :pref:-vapid pic x(80).
               03 :pref:-build.
                   04 :pref:-build-commit-sha pic x(80).
                   04 :pref:-build-commit-timestamp pic x(80).
                   04 :pref:-build-semver pic x(80).
                   04 :pref:-build-origin-url pic x(80).
                   04 :pref:-build-timestamp pic x(80).
