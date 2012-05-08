module ValidationKit
  class MixedCaseValidator < ActiveModel::EachValidator
    ALL_CAPS = 1
    ALL_LOWERCASE = -1

    def validate_each(record, attribute, value)
      return if value.nil?
      return if value.gsub(/\W/, "").size < 3 # skip very short words
      error = nil

      if (value.upcase == value)
        error = ALL_CAPS
      elsif (value.downcase == value)
        error = ALL_LOWERCASE
      end

      return if error.nil?

      model_name = record.class.to_s

      item_name = I18n.t("activerecord.models.#{model_name.underscore}.attributes.#{attribute}",
                         :default => nil) or options[:attribute_name] or attribute

      if error == ALL_CAPS
       message = I18n.t("activerecord.errors.models.#{model_name.underscore}.attributes.#{attribute}.all_caps",
                   :item => item_name,
                   :default => [:"activerecord.errors.models.#{model_name.underscore}.all_caps",
                                options[:all_caps],
                                :'activerecord.errors.messages.all_caps'])
      elsif error == ALL_LOWERCASE
        message = I18n.t("activerecord.errors.models.#{model_name.underscore}.attributes.#{attributes}.all_lowercase",
                    :item => item_name,
                    :default => [:"activerecord.errors.models.#{model_name.underscore}.all_lowercase",
                                 options[:all_lowercase],
                                 :'activerecord.errors.messages.all_lowercase'])
      end

      record.errors.add(attribute, message)

    end
  end
end
