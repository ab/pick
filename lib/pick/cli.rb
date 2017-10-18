require 'tty/prompt'
require 'tty/screen'

module Pick
  class CLI

    # Read items from input_io and prompt the user to choose among them. Then
    # print the output to options[:output_io] or stdout.
    #
    # @param input_io [IO] The input IO from which to read the items
    # @param options [Hash] See {.prompt}
    # @option options :output_io [IO] (STDOUT) The IO to print selected items
    #   to.
    # @option options :output_delimiter [String] ("\n") The delimiter to print
    #   after each selected item.
    #
    def self.run(input_io, options={})
      answer = prompt(input_io, options)

      return if answer.empty?

      output_io = options[:output_io] || STDOUT

      out_sep = options[:output_delimiter]
      out_sep ||= "\n"

      output_io.print(Array(answer).join(out_sep) + out_sep)

      answer
    end

    # Read items from input_io and prompt the user to choose among them.
    #
    # @param input_io [IO] The input IO from which to read the items
    # @param options [Hash]
    # @option options :prompt_input [IO] IO to use for prompt input
    # @option options :prompt_output [IO] IO to use for prompt output
    # @option options :tty_dev [String] ('/dev/tty') The device to use as the
    #   default for TTY i/o, used for :prompt_input and :prompt_output
    # @option options :input_delimiter [String] The string that separates items
    #   on the input stream.
    # @option options :multiple [Boolean] Whether to select a single item or
    #   multiple items
    #
    # @return [String, Array<String>] A single item or an array of items chosen
    #   by the user.
    #
    def self.prompt(input_io, options={})
      prompt_opts = {}
      options = options.dup

      tty_dev = options[:tty_dev] || '/dev/tty' # TODO windows?

      options[:prompt_input] ||= File.open(tty_dev, 'r')
      options[:prompt_output] ||= File.open(tty_dev, 'a')

      options[:per_page] ||= TTY::Screen.height - 2
      if options[:per_page] && options[:per_page] >= 1
        prompt_opts[:per_page] = options.fetch(:per_page)
      end

      if input_io.tty? && options.fetch(:prompt_output).tty? \
         && !options[:quiet]
        options.fetch(:prompt_output).puts('Waiting for input items...')
      end

      # read the input io
      data = input_io.read

      # set default separator
      separator = options[:input_delimiter]
      if separator.nil?
        data.gsub!("\r\n", "\n")
        separator = "\n"
      end

      # split input into choices
      choices = data.split(separator)

      p = TTY::Prompt.new(
        input: options.fetch(:prompt_input),
        output: options.fetch(:prompt_output)
      )

      if options[:multiple]
        prompt = options.fetch(:prompt, 'Select multiple items:')
        p.multi_select(prompt, choices, prompt_opts)
      else
        prompt = options.fetch(:prompt, 'Select an item:')
        p.select(prompt, choices, prompt_opts)
      end
    end
  end
end
