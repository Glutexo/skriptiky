#!/usr/bin/ruby

=begin
Changes the interpreter header of each script in the current
directory. Can be used to change the ruby version in case it
is directly written there by RVM and the upgrade process
didn’t change it.
=end

usage = <<EOS
USAGE: change-interpreter.rb SEARCH_PATTERN REPLACE_PATTERN
EXAMPLE: change-interpreter.rb "-p247/" "-p353/"
EOS

SEARCH_PATTERN, REPLACE_PATTERN = ARGV
if SEARCH_PATTERN.nil?
  puts "ERROR: Search pattern cannot be empty."
  puts
  puts usage
  exit
end

if REPLACE_PATTERN.nil?
  puts "ERROR: Search pattern cannot be empty."
  puts
  puts usage
  exit
end

dir = Dir.new '.'
dir.each do |entry|
  next if File.directory? entry

  output = ""
  file_read = File.new entry, 'r'

  file_read.each_line do |line|
    line = line.gsub SEARCH_PATTERN, REPLACE_PATTERN if line =~ /^#\!/
    output += line
  end

  file_write = File.new entry, 'w'
  file_write.write output
end
