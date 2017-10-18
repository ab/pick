require 'tty/prompt'
require 'tty/screen'

module Pick
  class CLI
    def self.run(input_io, options={})
      answer = prompt(input_io, options)

      output_io = options[:output_io] || STDOUT

      out_sep = options[:output_delimiter]
      out_sep ||= "\n"

      output_io.print(Array(answer).join(out_sep) + out_sep)
    end

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

      prompt = options.fetch(:prompt, 'Pick an option:')

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
