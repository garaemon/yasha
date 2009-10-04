(defsystem yasha
  :depends-on (chimi usocket)
  :components
  ((:file "yasha")
   (:file "socket" :depends-on ("yasha")))
  )

