# encoding: utf-8

module SpreeActiveSale
  module Eventable
    module ClassMethods

      def paginate(objects_per_page, options = {})
        options = prepare_pagination(objects_per_page, options)
        self.page(options[:page]).per(options[:per_page])
      end

      private
        def valid_argument args
          (args.first == nil || args.first == true)
        end

        def prepare_pagination(objects_per_page, options)
          per_page = options[:per_page].to_i
          options[:per_page] = per_page > 0 ? per_page : Spree::ActiveSaleConfig[objects_per_page]
          page = options[:page].to_i
          options[:page] = page > 0 ? page : 1
          options
        end

        def zone_time
          Time.zone.now
        end
    end
    
    module InstanceMethods

      def validate_start_and_end_date
        errors.add(:start_date, I18n.t('spree.active_sale.event.validation.errors.invalid_dates')) if invalid_dates?
      end

      def live?
        current_time = object_zone_time
        (self.start_date <= current_time and self.end_date >= current_time) or self.is_permanent? if start_and_dates_available?
      end

      def upcoming?
        current_time = object_zone_time
        (self.start_date >= current_time and self.end_date > self.start_date) if start_and_dates_available?
      end

      def past?
        current_time = object_zone_time
        (self.start_date < current_time and self.end_date > self.start_date and self.end_date < current_time) if start_and_dates_available?
      end

      def live_and_active?
        self.live? and self.is_active?
      end

      def start_and_dates_available?
        self.start_date and self.end_date
      end

      def invalid_dates?
        self.start_and_dates_available? and (self.start_date >= self.end_date)
      end

      private
        def object_zone_time
          Time.zone.now
        end
    end
    
    def self.included(receiver)
      receiver.extend         ClassMethods
      receiver.send :include, InstanceMethods
    end
  end
end