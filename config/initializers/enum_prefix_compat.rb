# Backwards-compatibility shim: accept :_prefix option for enums
# Some older code or generated files may use :_prefix instead of :prefix.
# Rails enum validates options strictly; normalize :_prefix -> :prefix
# Backwards-compatibility shim: accept :_prefix option for enums
# Some generated or older code may use :_prefix instead of :prefix.
# We hook into ActiveRecord after it's loaded and prepend into the
# enum class methods so calls like `enum ..., _prefix: true` are
# normalized to `prefix: true` before validation.
ActiveSupport.on_load(:active_record) do
  if defined?(ActiveRecord::Enum::ClassMethods)
    compat = Module.new do
      def enum(definitions = nil, **options)
        if options.key?(:_prefix)
          options[:prefix] = options.delete(:_prefix)
        end
        super(definitions, **options)
      end
    end

    ActiveRecord::Enum::ClassMethods.prepend(compat)
  end
end
