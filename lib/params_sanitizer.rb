
module Headbanger

  module ParamsSanitizer

    def self.included( base )
      base.send( :include, Headbanger::ParamsSanitizer::InstanceMethods )
      base.extend( Headbanger::ParamsSanitizer::ClassMethods )
    end

    module InstanceMethods

      protected

      def is_form_submission?
        self.request.post? || self.request.put?
      end

      def strip_tags_from_params(_params = params)
        return true unless is_form_submission?
        walk_hash( _params ) do |value|
          ActionView::Base.full_sanitizer.sanitize(value)
        end
        true
      end

      def sanitize_params( _params = params )
        return true unless is_form_submission?
        walk_hash( _params ) do |value|
          ActionView::Base.white_list_sanitizer.sanitize(value)
        end
        true
      end

      def walk_hash(hash, &block)
        hash.keys.each do |key|
          hash[key] = case hash[key]
          when String
            block.call(hash[key])
          when Hash
            walk_hash(hash[key], &block)
          when Array
            walk_array(hash[key], &block)
          else
            hash[key]
          end
        end
        hash
      end

      def walk_array(array, &block)
        array.each_with_index do |el,i|
          array[i] = case el
          when String
            block.call(el)
          when Hash
            walk_hash(el, &block)
          when Array
            walk_array(el, &block)
          else
            array[i]
          end
        end
        array
      end

    end

    module ClassMethods

      def strip_tags_from_params( options = {} )
        before_filter :strip_tags_from_params, options
      end

      def disable_strip_tags_from_params
        skip_before_filter :strip_tags_from_params
      end

      def sanitize_params( options = {} )
        before_filter :sanitize_params, options
      end

      def disable_sanitize_params
        skip_before_filter :sanitize_params
      end

    end

  end

end