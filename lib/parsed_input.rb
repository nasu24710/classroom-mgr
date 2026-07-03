class ParsedInput < Data.define(:command_name, :arguments, :options)
    def initialize(command_name:, arguments:, options:)
        unless command_name.is_a?(String)
            raise ArgumentError, "command_name must be a String"
        end
        unless arguments.is_a?(Array)
            raise ArgumentError, "arguments must be an Array"
        end
        unless options.is_a?(Hash)
            raise ArgumentError, "options must be a Hash"
        end

        super(command_name: command_name, arguments: arguments, options: options)
    end
end