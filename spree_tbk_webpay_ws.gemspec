# -*- encoding: utf-8 -*-
# stub: spree_tbk_webpay 1.2.6 ruby lib

Gem::Specification.new do |s|
  s.name = "spree_tbk_webpay_ws"
  s.version = "2.1.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["Felipe Cano", "Ignacio Mella"]
  s.date = "2016-08-29"
  s.description = "Plugs Webpay Webservice Payment Gateway into Spree Stores"
  s.email = ["felipe@acid.cl", "ignacio@acid.cl"]
  s.homepage = "http://www.acid.cl"
  s.required_ruby_version = Gem::Requirement.new(">= 1.9.3")
  s.requirements = ["none"]
  s.rubygems_version = "2.4.8"
  s.summary = "Plugs Webpay Webservices Payment Gateway into Spree Stores"

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<spree_core>, ["~> 2.1.3"])
      s.add_development_dependency(%q<capybara>, ["~> 2.1"])
      s.add_development_dependency(%q<coffee-rails>, [">= 0"])
      s.add_development_dependency(%q<database_cleaner>, [">= 0"])
      s.add_development_dependency(%q<factory_girl>, ["~> 4.2"])
      s.add_development_dependency(%q<ffaker>, [">= 0"])
      s.add_development_dependency(%q<rspec-rails>, ["~> 2.13"])
      s.add_development_dependency(%q<sass-rails>, [">= 0"])
      s.add_development_dependency(%q<selenium-webdriver>, [">= 0"])
      s.add_development_dependency(%q<simplecov>, [">= 0"])
      s.add_development_dependency(%q<sqlite3>, [">= 0"])
      s.add_development_dependency(%q<multi_logger>, [">= 0.1"])
    else
      s.add_dependency(%q<spree_core>, ["~> 2.1.3"])
      s.add_dependency(%q<capybara>, ["~> 2.1"])
      s.add_dependency(%q<coffee-rails>, [">= 0"])
      s.add_dependency(%q<database_cleaner>, [">= 0"])
      s.add_dependency(%q<factory_girl>, ["~> 4.2"])
      s.add_dependency(%q<ffaker>, [">= 0"])
      s.add_dependency(%q<rspec-rails>, ["~> 2.13"])
      s.add_dependency(%q<sass-rails>, [">= 0"])
      s.add_dependency(%q<selenium-webdriver>, [">= 0"])
      s.add_dependency(%q<simplecov>, [">= 0"])
      s.add_dependency(%q<sqlite3>, [">= 0"])
      s.add_development_dependency(%q<multi_logger>, [">= 0.1"])
    end
  else
    s.add_dependency(%q<spree_core>, ["~> 2.1.3"])
    s.add_dependency(%q<capybara>, ["~> 2.1"])
    s.add_dependency(%q<coffee-rails>, [">= 0"])
    s.add_dependency(%q<database_cleaner>, [">= 0"])
    s.add_dependency(%q<factory_girl>, ["~> 4.2"])
    s.add_dependency(%q<ffaker>, [">= 0"])
    s.add_dependency(%q<rspec-rails>, ["~> 2.13"])
    s.add_dependency(%q<sass-rails>, [">= 0"])
    s.add_dependency(%q<selenium-webdriver>, [">= 0"])
    s.add_dependency(%q<simplecov>, [">= 0"])
    s.add_dependency(%q<sqlite3>, [">= 0"])
    s.add_development_dependency(%q<multi_logger>, [">= 0.1"])
  end
end
