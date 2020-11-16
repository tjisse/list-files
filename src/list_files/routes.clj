(ns list-files.routes
  (:require [compojure.api.sweet :refer :all]))

(defroutes all-routes
  (api
   (GET "/" [] {:status 200 :body {:name "test"}})))
