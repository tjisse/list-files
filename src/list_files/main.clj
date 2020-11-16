(ns list-files.main
  (:require [environ.core :refer [env]]
            [mount.core :as mount :refer [defstate]]
            [list-files.routes :refer [all-routes]]
            [org.httpkit.server :refer [run-server]]
            [muuntaja.middleware :as middleware])
  (:gen-class))

(defonce default-http-port 8080)
(defonce server-stop-timeout-ms 100)

(defstate server
  :start (run-server (middleware/wrap-format all-routes)
                     {:port (or (env :http-port) default-http-port)})
  :stop (server :timeout server-stop-timeout-ms))

(defn -main [& args]
  (mount/start))

(.addShutdownHook (Runtime/getRuntime) (Thread. ^Runnable mount/stop))

(comment
  (mount/stop))
