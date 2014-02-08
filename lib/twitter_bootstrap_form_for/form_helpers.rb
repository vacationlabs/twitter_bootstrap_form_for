require 'twitter_bootstrap_form_for'

module TwitterBootstrapFormFor::FormHelpers
  [:form_for, :fields_for].each do |method|
    module_eval do
      define_method "twitter_bootstrap_#{method}" do |record, *args, &block|
        # add the TwitterBootstrap builder to the options
        options           = args.extract_options!
        options[:builder] = TwitterBootstrapFormFor::FormBuilder

        # call the original method with our overridden options
        _override_field_error_proc do
          send method, record, *(args << options), &block
        end
      end
    end
  end

  def ng_bootstrap_form_for(record, *args, &proc)
    raise ArgumentError, "Missing block" unless block_given?

    # add the TwitterBootstrap builder to the options
    options           = args.extract_options!
    options[:builder] = TwitterBootstrapFormFor::FormBuilder
    # ng_model          = (options.delete('ng-model') || options.delete(:ng_model))

    # call the original method with our overridden options
    # _override_field_error_proc do
    #   send method, record, *(args << options), &block
    # end

    options[:html] ||= {}

    object      = nil
    object_name = options[:as] || ActiveModel::Naming.param_key(object)

    # case record
    # when String, Symbol
    #   object_name = record
    #   object      = nil
    # else
    #   object      = record.is_a?(Array) ? record.last : record
    #   object_name = options[:as] || ActiveModel::Naming.param_key(object)
    #   apply_form_for_options!(record, options)
    # end

    options[:html][:remote] = options.delete(:remote) if options.has_key?(:remote)
    options[:html][:method] = options.delete(:method) if options.has_key?(:method)
    options[:html][:authenticity_token] = options.delete(:authenticity_token)

    builder = options[:parent_builder] = instantiate_builder(object_name, object, options, &proc)
    fields_for = fields_for(object_name, object, options, &proc)
    # default_options = builder.multipart? ? { :multipart => true } : {}
    output = content_tag(:div, {'ng-form' => '', 'name' => record}.merge!(options.delete(:html))) do 
      fields_for
    end
    # output.safe_concat('</form>')
    # output = content_tag(:div, form_tag(options.delete(:url) || {}, default_options.merge!(options.delete(:html)))
    # output << fields_for
    # output.safe_concat('</form>')
  end

  private

  BLANK_FIELD_ERROR_PROC = lambda {|input, *_| input }

  def _override_field_error_proc
    original_field_error_proc           = ::ActionView::Base.field_error_proc
    ::ActionView::Base.field_error_proc = BLANK_FIELD_ERROR_PROC
    yield
  ensure
    ::ActionView::Base.field_error_proc = original_field_error_proc
  end
end
