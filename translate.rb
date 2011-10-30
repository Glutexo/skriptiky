#!/usr/bin/ruby

=begin

Projde zvolený adresář a u souborů, které vyhovují zadání (match) provede
jednak nahrazení za replacement a jednak překlad řetězců podle translate.

Motivací k tomuto programuje skutečnost, že některé archívy mají po
rozbalení špatné kódování názvů souborů a tímto je možné ho napravit, ačkoli
je potřeba si překladovou tabulku nadefinovat ručně. Přejmenování podle
vzoru je pak jen zabití dvou much jednou ranou.

=end

basedir = '.'
match, replacement = /(\d{3}) -/, '\1'
translate = {
	'ā' => 'é',
	'°' => 'í',
	'ō' => 'ě',
	'ß' => 'ž',
	'†' => 'á',
	'ž' => 'ý',
	'Ö' => 'ů',
	'¶' => 'Ž',
	'Á' => 'š',
	'¨' => 'Č',
	'ż' => 'ř',
	'‘' => 'ď',
	'£' => 'ú',
	'ü' => 'č',
	'Ę' => 'ó',
	'Ś' => 'ň',
	'ś' => 'Š'}

class String
  # PHP's two argument version of strtr
  # from http://blade.nagaokaut.ac.jp/cgi-bin/scat.rb/ruby/ruby-talk/183772
  def strtr(replace_pairs)
    keys = replace_pairs.map {|a, b| a }
    values = replace_pairs.map {|a, b| b }
    self.gsub(
      /(#{keys.map{|a| Regexp.quote(a) }.join( ')|(' )})/
      ) { |match| values[keys.index(match)] }
  end
end

Dir.new(basedir).entries.each do |entry|
	File.rename(entry, entry.gsub(match, replacement).strtr(translate)) if entry.match match
end