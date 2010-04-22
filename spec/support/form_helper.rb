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

  def have_tag_with_attributes_as_hash(tag, *args, &block)
    args.extract_options!.each do |attribute_name,value|
      tag << "[#{ attribute_name }=?]"
      args << value
    end

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

  have_field_by_type_helper(:text)
  have_field_by_type_helper(:password)
  have_field_by_type_helper(:checkbox)

  form_by_method_helper(:post)
  form_by_method_helper(:get)
end

class Spec::Rails::Example::ViewExampleGroup
  include ::FormHelper
end
