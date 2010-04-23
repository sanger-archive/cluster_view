module Spec::DSL::Main
  def view_spec_for(path, &block)
    describe("/#{ path }", :type => :view) do
      before(:each) { render(path) }

      it 'should render (to prove it exists!)' do
        response.should_not be_nil
      end

      module_eval(&block) if block_given?
    end
  end

  def layout_spec_for(layout, &block)
    describe("layouts/#{ layout }", :type => :view) do
      before(:each) do
        @controller.template.stub!(:current_page?).with(any_args).and_return(false)
        flash[:message] = 'FLASH MESSAGE'
        flash[:error] = 'FLASH ERROR'
        render :text => 'CONTENT FOR LAYOUT', :layout => layout
      end

      it 'should render the content' do
        response.body.should match('CONTENT FOR LAYOUT')
      end

      module_eval(&block) if block_given?
    end
  end
end

module LinkHelper
  def have_link_to(path, *args, &block)
    options = { :href => path }.merge(args.extract_options!.symbolize_keys)
    args.push(options)
    have_tag('a', *args, &block)
  end
end

class Spec::Rails::Example::ViewExampleGroup
  include ::LinkHelper
  
  class << self
    def it_renders_flash_field(field)
      it "displays the flash[#{ field.inspect }]" do
        response.should have_tag("#flash .#{ field }")
      end
    end
  end
end
