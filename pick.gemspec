require_relative './lib/pick/version'

Gem::Specification.new do |spec|
  spec.name          = 'pick'
  spec.version       = Pick::VERSION
  spec.authors       = ['Andy Brody']
  spec.email         = ['git@abrody.com']

  spec.summary       = 'Pick is a CLI tool to select from multiple options.'
  spec.description   = <<-EOM
    Pick is a command line tool to interactively select from multiple options.
    It accepts options from a file or stdin, and outputs the selected value or
    values to stdout.

    See also: ipt, percol, sentaku
  EOM
  spec.homepage      = 'https://github.com/ab/pick'
  spec.license       = 'GPL-3'

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'bin'
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency('tty-prompt', '~> 0.13')
  spec.add_dependency('tty-screen', '~> 0.5')

  spec.add_development_dependency 'bundler', '~> 1.14'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'pry'
end
