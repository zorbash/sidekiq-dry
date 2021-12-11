require_relative 'lib/sidekiq/dry/version'

Gem::Specification.new do |spec|
  spec.name          = "sidekiq-dry"
  spec.version       = Sidekiq::Dry::VERSION
  spec.authors       = ["Dimitris Zorbas"]
  spec.email         = ["dimitrisplusplus@gmail.com"]

  spec.summary       = %q{Dry::Struct arguments for Sidekiq jobs}
  spec.description   = %q{Gem to provide serialization and deserialization of Dry::Struct arguments for Sidekiq jobs}
  spec.homepage      = 'https://github.com/zorbash/sidekiq-dry'
  spec.license       = "MIT"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.3.0")

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = 'https://github.com/zorbash/sidekiq-dry'
  spec.metadata["changelog_uri"] = 'https://github.com/zorbash/sidekiq-dry/CHANGELOG.md'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency 'sidekiq', '>= 6.2.1'
  spec.add_dependency 'dry-struct', '~> 1.0'
  spec.add_dependency 'activesupport'

  spec.add_development_dependency 'rake', '~> 12.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'pry'
end
