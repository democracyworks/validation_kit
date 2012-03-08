module ValidationKit
  class MixedCaseValidator < ActiveModel::EachValidator
    ALL_CAPS = 1
    ALL_LOWERCASE = -1

    def validate_each(record, attribute, value)
      next if value.nil?
      next if value.gsub(/\W/, "").size < 3 # skip very short words
      error = nil

      if (value.upcase == value)
        error = ALL_CAPS
      elsif (value.downcase == value)
        error = ALL_LOWERCASE
      end

      next if error.nil?

      item_name = I18n.t("activerecord.models.attributes.#{name.underscore}.#{attribute}",
                         :default => nil) or options[:attribute_name] or attribute

      if error == ALL_CAPS
       message = I18n.t("activerecord.errors.models.attributes.#{name.underscore}.#{attr_name}.all_caps",
                   :item => item_name,
                   :default => [:"activerecord.errors.models.#{name.underscore}.all_caps",
                                options[:all_caps],
                                :'activerecord.errors.messages.all_caps'])
      elsif error == ALL_LOWERCASE
        message = I18n.t("activerecord.errors.models.attributes.#{name.underscore}.#{attr_name}.all_lowercase",
                    :item => item_name,
                    :default => [:"activerecord.errors.models.#{name.underscore}.all_lowercase",
                                 options[:all_lowercase],
                                 :'activerecord.errors.messages.all_lowercase'])
      end

      record.errors[attribute] << message

    end
  end
end
