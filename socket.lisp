;;================================================
;; socket.lisp
;;
;; written by R.Ueda (garaemon)
;;================================================

(in-package :yasha)

(defun format-to-socket (sock str &rest args)
  (apply #'format (socket-stream sock) str args)
  (force-output (socket-stream sock)))

(defun print-to-socket (val sock)
  (print val (socket-stream sock))
  (force-output (socket-stream sock)))

(defclass* <socket-server>
    ()
  ((host "localhost")
   (port 5500)
   (socket nil)
   (receive-thread nil)
   (receive-mutex (make-mutex))))

(defmethod read-proc ((server <socket-server>) socket mutex)
  ;; default, work as a echo server
  (let ((line (read-line (socket-stream socket) nil)))
    (if line
        (progn
          (format t "~A~%" line)
          t)
        nil)))

(defmethod read-loop ((server <socket-server>) socket mutex)
  (while (read-proc server socket mutex))
  (format t "bye...~%")
  (close (socket-stream socket)))

(defmethod receive-proc ((server <socket-server>))
  (let ((socket (socket-accept (socket-of server))))
    (format t "new connection!~%")
    (with-mutex ((receive-mutex-of server))
      ;; この中はclientの接続が確立されたら呼ばれる
      ;; read-loopを実行するthreadを作って抜ける
      (make-thread
             #'(lambda ()
                 (read-loop server socket (make-mutex))))
      )))

(defmethod start-server ((server <socket-server>))
  (let ((sock (socket-listen (host-of server) (port-of server) :reuseaddress t)))
    (setf (socket-of server) sock)
    (setf (receive-thread-of server)
          (make-thread
           #'(lambda ()
               (while t
                 (receive-proc server)))))
    )
  )

(defmethod connect-to-server ((server <socket-server>))
  (let ((sock (socket-connect (host-of server) (port-of server))))
    (format t "connection established~%")
    (setf (socket-of server) sock)))


