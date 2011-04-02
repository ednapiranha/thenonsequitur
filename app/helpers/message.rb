module Sinatra
	module Message
		include Rack::Utils
		alias_method :h, :escape_html

		def versioned_css(stylesheet)
	    "/stylesheets/#{stylesheet}.css?" + File.mtime(File.join(Sinatra::Application.views, "stylesheets", "#{stylesheet}.sass")).to_i.to_s
	  end

		def versioned_js(js)
		  "/javascripts/#{js}.js?" + File.mtime(File.join(Sinatra::Application.public, "javascripts", "#{js}.js")).to_i.to_s
		end
	end
	
	helpers Message
end