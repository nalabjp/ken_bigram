require 'optparse'
require_relative 'lib/ken_bigram'

update = false

opt = OptionParser.new
opt.on('-u', '--update') { update = true }
opt.parse!(ARGV)

KenBigram.generate(update: update)
