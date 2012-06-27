Kernel.load 'lib/mpd/version.rb'

Gem::Specification.new {|s|
	s.name         = 'mpd'
	s.version      = MPD.version
	s.author       = 'meh.'
	s.email        = 'meh@paranoici.org'
	s.homepage     = 'http://github.com/meh/ruby-mpd'
	s.platform     = Gem::Platform::RUBY
	s.summary      = 'MPD controller library.'

	s.files         = `git ls-files`.split("\n")
	s.executables   = `git ls-files -- bin/*`.split("\n").map { |f| File.basename(f) }
	s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
	s.require_paths = ['lib']
}
