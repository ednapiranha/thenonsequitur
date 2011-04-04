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
		
		def clean(w)
			w.to_s.gsub(/[^A-Za-z0-9_-]/, '').downcase
		end
		
		def soft_clean(w)
			w.to_s.gsub(/<|>/, ' ')
		end
		
		def is_valid(w)
			clean(w).length > 2 and !clean(w).match(/(this|there|their|and|was|has|had|have|but|wasnt|hasnt|would|wouldnt|where|here|theyre|are|they|the|them)/)
		end
		
		def tag_size(tag)
			(Math::log10(tag.total_count) * 30).to_i
		end
	end
	
	helpers Message
end