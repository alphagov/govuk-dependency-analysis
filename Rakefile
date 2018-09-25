require 'yaml'
require 'json'
require 'http'

Version = Struct.new(:name, :version, :name_and_version)

def counts(array)
  array.each_with_object(Hash.new(0)) { |el, counts| counts[el] += 1 }
end

require_relative 'app/gemfiles'
require_relative 'app/dependency'
require_relative 'app/application'
require_relative 'app/base_data'
require_relative 'app/jaccard_matrix'
require_relative 'app/fragmentation'
require_relative 'app/network'

desc "Download & rebuild everything"
task rebuild: %i[download_gemfiles precalculate_data generate_similarity]

desc "Download the Gemfiles for the applications"
task :download_gemfiles do
  Gemfiles.download
end

desc "Outputs all the applictions and gems they depend on, gems and apps they depend on"
task :precalculate_data do
  BaseData.generate
  Network.generate
  Fragmentation.generate
end

desc "Create similarity data (takes a while)"
task :generate_similarity do
  JaccardMatrix.generate
end
