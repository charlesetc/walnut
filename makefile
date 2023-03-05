build-gem:
	gem build
	gem install ./walnut-*.gem

irb: 
	@bundle exec irb -r ./lib/walnut.rb 
