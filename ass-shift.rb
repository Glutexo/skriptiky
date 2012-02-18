#!/usr/bin/ruby

src, shift = ARGV
raise ArgumentError, 'Je potřeba zadat soubor s titulky' if src === nil
src.match /\.([^\.]+)$/
raise ArgumentError, 'Titulky musejí být prdel.' if $1 != 'ass'
shift = 0 if shift === nil
shift = shift.to_f

# převede prdelní formát (viz níže) na počet sekund
def to_secs line
	line = line.split(':').reverse
	mins = line[1].to_f + line[2].to_f * 60;
	secs = line[0].to_f + mins * 60
end

# převede sekundy na prdelní formát, viz níže
def to_time secs
	abssecs, decimal = secs.to_s.split '.'
	abssecs = abssecs.to_i
	secs = (abssecs.to_i) % 60
	allmins = (abssecs - secs) / 60
	mins = allmins % 60
	hrs = (allmins - mins) / 60
	sprintf('%d', hrs) + ':' + sprintf('%02d', mins) + ':' + sprintf('%02d', secs) + '.' + decimal
end

time = '([\\d:\\.]+)(,)' # např. 0:01:50.40,0:01:55.12,

lines = []
f = File.new src
begin
	while line = f.readline
		line.chomp!
		# řádky s titulky
		if line =~ Regexp.new('(^Dialogue: \\d+,)' + time + time + '(.+)$')
			lprefix, lbegin, lsep1, lend, lsep2, lsuffix = $1, to_secs($2), $3, to_secs($4), $5, $6
			sbegin, send = to_time(lbegin + shift), to_time(lend + shift)
			lines.push lprefix + sbegin + lsep1 + send + lsep2 + lsuffix
		else # ostatní necháme být
			lines.push line
		end
	end
rescue EOFError
	f.close
end

print lines.join "\n"