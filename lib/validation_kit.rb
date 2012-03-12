require "validation_kit/version"

lib_path = File.dirname(__FILE__)
validators = Dir[File.join(lib_path, '**', '*_validator.rb')]
validators.each do |v|
  require v
  validator_class = File.basename(v, '.rb').camelize
  validator = "ValidationKit::#{validator_class}".constantize
  ActiveModel::Validations.const_set(validator_class, validator)
end
