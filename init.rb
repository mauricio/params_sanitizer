require 'params_sanitizer'

ActionController::Base.send( :include, Headbanger::ParamsSanitizer )