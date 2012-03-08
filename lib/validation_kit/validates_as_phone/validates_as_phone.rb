module ActiveRecord
  module Validations
    module ClassMethods
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

      def validates_as_phone(*args)        
        configuration = { :with => nil, :area_key => :phone_area_key }
        configuration.update(args.pop) if args.last.is_a?(Hash)
        
        validates_each(args, configuration) do |record, attr_name, value|
          if configuration[:country].is_a?(String)
            country = configuration[:country]
          elsif configuration[:country].is_a?(Symbol) and record.respond_to?(configuration[:country])
            country = record.send(configuration[:country])
          elsif record.respond_to?(:country)
            country = record.send(:country)
          else
            country = false
          end

          next unless country          
          current_regex = regex_for_country(country)
          next unless current_regex

          new_value = value.to_s.gsub(/[^0-9]/, '')
          new_value ||= ''

          message = I18n.t("activerecord.errors.models.#{name.underscore}.attributes.#{attr_name}.invalid", 
                                        :default => [:"activerecord.errors.models.#{name.underscore}.invalid", 
                                                    configuration[:message],
                                                    :'activerecord.errors.messages.invalid'])

          unless (configuration[:allow_blank] && new_value.blank?) || new_value =~ current_regex
            record.errors.add(attr_name, message)
          else
            if configuration[:set]
              formatted_phone = format_as_phone(value, country, configuration[:area_key])
              if formatted_phone.nil?
                record.errors.add(attr_name, message)
              else
                record.send(attr_name.to_s + '=', formatted_phone)
              end
            end # configuration
          end # unless
        end # validates_each
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
          when 'NSW': '02'
          when 'ACT': '02'
          when 'VIC': '03'
          when 'TAS': '03'
          when 'QLD': '07'
          when 'SA' : '08'
          when 'NT' : '08'
          when 'WA' : '08'
        else
          '02'
        end
      end
    end    
  end
end
