(ns user
  (:require [mount.core :refer [start stop]]))

(set! *warn-on-reflection* true)

(defn start-system! []
  (start))

(defn stop-system! []
  (stop))
