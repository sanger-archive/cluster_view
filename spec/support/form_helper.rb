module FormHelper
  def self.included(base)
    # Ordering here is semi-important, with have_tag_with_attributes_as_hash definitely needing to be first
    # so that it is last in the chained method stack before the default have_tag implementation.
    base.alias_method_chain(:have_tag, :attributes_as_hash)
    base.alias_method_chain(:have_tag, :form_object_name)
    base.extend(ClassMethods)
    base
  end

  module ClassMethods
    def with_a_form_for(form_object_name, &block)
      context "with a form dealing with #{ form_object_name }" do
        before(:each) do
          @form_target_object_name = form_object_name
        end

        after(:each) do
          @form_target_object_name = nil
        end

        self.instance_eval(&block)
      end
    end
  end
  
  ATTRIBUTES_THAT_ARE_NOT_HTML = [ :count ]

  def have_tag_with_attributes_as_hash(tag, *args, &block)
    tag, attributes = tag.to_s, args.extract_options!

    options = (ATTRIBUTES_THAT_ARE_NOT_HTML & attributes.keys).inject({}) do |options,name|
      options[ name ] = attributes.delete(name)
      options
    end
    
    attributes.each do |attribute_name,value|
      tag << "[#{ attribute_name }=?]"
      args << value
    end
    args.push(options)

    have_tag_without_attributes_as_hash(tag, *args, &block)
  end

  def have_tag_with_form_object_name(tag, *args, &block)
    options = args.extract_options!.symbolize_keys
    if not @form_target_object_name.nil? and options.key?(:name)
      options[ :name ] = "#{ @form_target_object_name }[#{ options[ :name ] }]"
    end
    args.push(options)
    have_tag_without_form_object_name(tag, *args, &block)
  end

  class << self
    def have_field_by_type_helper(type)
      define_method(:"have_#{ type }_field") do |attributes|
        have_tag('input', attributes.merge(:type => type.to_s))
      end
    end

    def form_by_method_helper(method)
      define_method(:"#{ method }_form_to") do |action_destination|
        have_tag('form', :method => method, :action => action_destination)
      end
    end
  end

  #--
  # Helpers for form fields:
  #
  #  have_text_field      => have_tag('input', :type => 'text')
  #  have_password_field  => have_tag('input', :type => 'password')
  #  have_checkbox_field  => have_tag('input', :type => 'checkbox')
  #  have_hidden_field    => have_tag('input', :type => 'hidden')
  #++
  have_field_by_type_helper(:text)
  have_field_by_type_helper(:password)
  have_field_by_type_helper(:checkbox)
  have_field_by_type_helper(:hidden)
  have_field_by_type_helper(:file)

  #--
  # Helpers for forms:
  #
  #  post_form_to(destination)  => have_tag('form', :method => 'post', :action => destination)
  #  get_form_to(destination)   => have_tag('form', :method => 'get', :action => destination)
  #  put_form_to(destination)   => have_tag('form', :method => 'post', :action => destination) [ with hidden '_method' field 'put' ]
  #++
  form_by_method_helper(:post)
  form_by_method_helper(:get)
  
  def put_form_to(action_destination, options = {})
    have_tag('form', options.update(:method => 'post', :action => action_destination)) do |form|
      form.first.should have_hidden_field(:name => '_method', :value => 'put')
    end
  end
end

class Spec::Rails::Example::ViewExampleGroup
  include ::FormHelper
end
