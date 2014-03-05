inputs = %w[
  CollectionSelectInput
  DateTimeInput
  FileInput
  GroupedCollectionSelectInput
  NumericInput
  PasswordInput
  RangeInput
  StringInput
  TextInput
]

inputs.each do |input_type|
  superclass = "SimpleForm::Inputs::#{input_type}".constantize

  new_class = Class.new(superclass) do
    def input_html_classes
      super.push('form-control')
    end
  end

  Object.const_set(input_type, new_class)
end
# Use this setup block to configure all options available in SimpleForm.
SimpleForm.setup do |config|
  config.wrappers :bootstrap, tag: 'div', class: 'form-group', error_class: 'has-error' do |b|
    b.use :html5
    b.use :placeholder
    b.use :label
    b.wrapper tag: 'div', class: 'col-md-7' do |ba|
      ba.use :input , error_class: 'has-error'
      ba.use :error, wrap_with: {tag: 'span', class: 'help-block'}
      ba.use :hint, wrap_with: {tag: 'p', class: 'help-block has-error'}
    end
  end

  config.wrappers :prepend, tag: 'div', class: "form-group", error_class: 'has-error' do |b|
    b.use :html5
    b.use :placeholder
    b.use :label
    b.wrapper tag: 'div', class: 'col-lg-9' do |input|
      input.wrapper tag: 'div', class: 'input-prepend' do |prepend|
        prepend.use :input
      end
      input.use :hint, wrap_with: {tag: 'span', class: 'help-block'}
      input.use :error, wrap_with: {tag: 'span', class: 'help-block has-error'}
    end
  end

  config.wrappers :append, tag: 'div', class: "form-group", error_class: 'has-error' do |b|
    b.use :html5
    b.use :placeholder
    b.use :label
    b.wrapper tag: 'div', class: 'col-lg-9' do |input|
      input.wrapper tag: 'div', class: 'input-append' do |append|
        append.use :input
      end
      input.use :hint, wrap_with: {tag: 'span', class: 'help-block'}
      input.use :error, wrap_with: {tag: 'span', class: 'help-block has-error'}
    end
  end

  # Wrappers for forms and inputs using the Twitter Bootstrap toolkit.
  # Check the Bootstrap docs (http://twitter.github.com/bootstrap)
  # to learn about the different styles for forms and inputs,
  # buttons and other elements.
  config.default_wrapper = :bootstrap
end
