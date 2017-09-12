module Metacrunch
  class Job::Dsl::OptionSupport
    require_relative "option_support/dsl"

    attr_reader :options

    def initialize(args, require_args: false, &block)
      @options = {}
      dsl.instance_eval(&block)

      dsl.options.each do |key, opt_def|
        # Set default value
        @options[key] = opt_def[:default]

        # Register with OptionParser
        if opt_def[:args].present?
          option = parser.define(*opt_def[:args]) { |value| @options[key] = value }

          option.desc << "REQUIRED" if opt_def[:required]
          option.desc << "DEFAULT: #{opt_def[:default]}" if opt_def[:default].present?

          parser_options[key] = option
        end
      end

      # Finally parse CLI options with OptionParser
      args = parser.parse(args || [])

      # Make sure required options are present
      ensure_required_options!(@options)

      # Make sure args are present if required
      ensure_required_args!(args) if require_args
    end

  private

    def parser
      @parser ||= OptionParser.new do |parser|
        parser.banner = "Usage: metacrunch [options] JOB_FILE @@ [job-options] [ARGS]\nJob options:"
      end
    end

    def parser_options
      @parser_options ||= {}
    end

    def dsl
      @dsl ||= Dsl.new
    end

    def ensure_required_options!(options)
      dsl.options.each do |key, opt_def|
        if opt_def[:required] && options[key].blank?
          long_option = parser_options[key].long.try(:[], 0)
          short_option = parser_options[key].short.try(:[], 0)

          puts "Error: Required job option `#{long_option || short_option}` missing."
          puts parser.help

          exit(1)
        end
      end
    end

    def ensure_required_args!(args)
      if args.blank?
        puts "Error: Required ARGS are missing."
        puts parser.help

        exit(1)
      end
    end

  end
end
