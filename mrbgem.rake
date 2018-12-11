MRuby::Gem::Specification.new('mruby-hashie') do |spec|
  spec.license = 'MIT'
  spec.authors = [
    'Michael Bleigh',
    'Jerry Cheung',
    'Takashi Kokubun',
  ]
  spec.add_dependency 'mruby-metaprog', core: 'mruby-metaprog'
end
