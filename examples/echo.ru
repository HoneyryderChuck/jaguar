ENV["RACK_ENV"] = "deployment"
APP = ->(env) {  
  [200, {}, ["echoing it all out!"]] 
}

run APP
