require "validation_kit/version"

validators = Dir[File.join(File.expand_path(File.join('..', __FILE__)), '**', '*.rb')]
validators.each do |v|
  require v
end

module ValidationKit; end
