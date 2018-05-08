
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "heroku_s3_backups/version"

Gem::Specification.new do |spec|
  spec.name          = "heroku_s3_backups"
  spec.version       = HerokuS3Backups::VERSION
  spec.authors       = ["joerodrig"]
  spec.email         = ["joerodrig3@gmail.com"]

  spec.summary       = "Easy Heroku DB backups to S3"
  spec.homepage      = "https://github.com/ableco/heroku_s3_backups"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"

  spec.add_runtime_dependency "s3", "~> 0.3"
end
