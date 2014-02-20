module Garamonde

end

Dir[ File.join(__dir__, 'garamonde', '*.rb') ].each do |lib|
  require lib
end
