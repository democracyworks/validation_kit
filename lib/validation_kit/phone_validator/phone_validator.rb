module ValidationKit
  class PhoneValidator < ActiveModel::EachValidator
    def regex_for_country(country_code)
      if country_code.blank?
        nil
      elsif ["AU"].include?(country_code)
        /(^(1300|1800|1900|1902)\d{6}$)|(^([0]?[1|2|3|7|8])?[1-9][0-9]{7}$)|(^13\d{4}$)|(^[0]?4\d{8}$)/
      elsif ["US", "CA"].include?(country_code)
        /^1?[2-9]\d{2}[2-9]\d{2}\d{4}/
      else
        nil
      end
    end

    def validate_each(record, attribute, value)
      if options[:country].is_a?(String)
        country = options[:country]
      elsif options[:country].is_a?(Symbol) && record.respond_to?(options[:country])
        country = record.send(options[:country])
      elsif record.respond_to?(:country)
        country = record.send(:country)
      else
        country = false
      end

      return unless country
      current_regex = regex_for_country(country)
      return unless current_regex

      new_value = value.to_s.gsub(/[^0-9]/, '')
      new_value ||= ''

      model_name = record.class.to_s

      message = I18n.t("activerecord.errors.models.#{model_name.underscore}.attributes.#{attribute}.invalid",
                       :default => [:"activerecord.errors.models.#{model_name.underscore}.invalid",
                       options[:message], :'activerecord.errors.messages.invalid'])

      unless (options[:allow_blank] && new_value.blank?) || new_value =~ current_regex
        record.errors.add(attribute, message)
      else
        if options[:set]
          formatted_phone = format_as_phone(value, country, options[:area_key])
          if formatted_phone.nil?
            record.errors.add(attribute, message)
          else
            record.send(attribute.to_s + '=', formatted_phone)
          end
        end # options
      end # unless
    end

    def format_as_phone(arg, country_code = nil, area_key = nil)
      return nil if (arg.blank? or country_code.blank? or !regex_for_country(country_code))

      number = arg.gsub(/[^0-9]/, '')

      if country_code == "AU"
        if number =~ /^(1300|1800|1900|1902)\d{6}$/
          number.insert(4, ' ').insert(8, ' ')
        elsif number =~ /^([0]?[1|2|3|7|8])?[1-9][0-9]{7}$/
          if number =~ /^[1-9][0-9]{7}$/
            number = number.insert(0, area_code_for_key(area_key))
          end
          number = number.insert(0, '0') if number =~ /^[1|2|3|7|8][1-9][0-9]{7}$/

          number.insert(0, '(').insert(3, ') ').insert(9, ' ')
        elsif number =~ /^13\d{4}$/
          number.insert(2, ' ').insert(5, ' ')
        elsif number =~ /^[0]?4\d{8}$/
          number = number.insert(0, '0') if number =~ /^4\d{8}$/

          number.insert(4, ' ').insert(8, ' ')
        else
          number
        end
      elsif ["CA", "US"].include?(country_code)
        digit_count = number.length
        # if it's too short
        if digit_count < 10
          return number
        end

        # strip off any leading ones
        if number[0..0] == "1"
          number = number[1..10]
        end

        area_code = number[0..2]
        exchange = number[3..5]
        sln = number[6..9]

        if digit_count == 10
          extension = nil
        else
          # save everything after the SLN as extension
          sln_index = arg.index(sln)
          # if something went wrong, return nil so we can error out
          # i.e. 519 444 000 ext 123 would cause sln to be 0001, which is not found
          # in the original string
          return nil if sln_index.nil?
          extension = " %s" % arg[(sln_index+4)..-1].strip
        end

        "(%s) %s-%s%s" % [area_code, exchange, sln, extension]
      end
    end

    def area_code_for_key(key)
      case key
        when 'NSW' then '02'
        when 'ACT' then '02'
        when 'VIC' then '03'
        when 'TAS' then '03'
        when 'QLD' then '07'
        when 'SA'  then '08'
        when 'NT'  then '08'
        when 'WA'  then '08'
      else
        '02'
      end
    end
  end
end
