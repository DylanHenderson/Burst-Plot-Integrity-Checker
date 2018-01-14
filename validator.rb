ARGV.each do|dir_name|

ranges = []
startings = []
file_names = []

Dir.foreach(dir_name) do |file_name_single|
	# Check real files
	next if file_name_single == '.' or file_name_single == '..'
	# Create full path for file name
	file_name = dir_name +"\\" + file_name_single
	begin

		size_reason = "File: #{file_name} has a size that would not fit a whole number of nonces. It's possible this just means that the last nonce cannot be read"

		# check the file exists 
		if !File.file?(file_name)
			puts "File #{file_name} does not exist, aborting"
			abort
		end
		size = File.size?(file_name)

		# Check name matches size
		if match = /_\d*_(\d*)_/.match(file_name)
			stated_nounces = (match.captures[0]).to_i
			nounces_start = /_(\d*)_/.match(file_name).captures[0].to_i
			# TODO error check here too I guess
			startings << nounces_start
			ranges << stated_nounces
			file_names << file_name
		 	stated_size = stated_nounces*262144
		 	puts "File: #{file_name} has a size of #{size} bytes which does not match the name of the file which states it has: #{stated_size}" if stated_size != size
		else
			puts "File name is odd, can't find number of nounces in name"
		end

		nonces_f = size/262144.0
		nonces = nonces_f.floor

		# only examine a small portion of the nonces to speed things up
		reads = nonces
		reads = nonces/1024 if nonces > 1024
		nonces > 1024 ? seek_skip = 1024*262144 : seek_skip = 262144

		# the amount of reads/nonces must be an integer, you cannot have half a nonce
		puts size_reason if nonces_f %1 !=0

		#Open the file
		File.open(file_name,"rb") { |f|
			puts "Examining #{reads} nonces out of #{nonces}"
			corrupt = Array.new(reads)
			# For each nonce, read in all the nonces bytes
			reads.times do |r|
				print "Examining nonce #{r*1024}\r"
				# If all the nonces are 0 assume that then the nonce is corrupt, store true if corrupt. Only examine first 16 bytes
				corrupt[r] = f.read(16).unpack("H*")[0] === "00000000000000000000000000000000"
				f.seek((seek_skip)-16,IO::SEEK_CUR)
			end
			# Ouput the bytes where the nonce is corrupt
			# TODO: options to concatanate for user
			# corrupt.each_with_index {|c,i| puts ("Corrupt nonce found from bytes:  #{262144*(i)*1024} to #{262144*(i+1)*1024}" ) if c }
			puts "Out of #{nonces} nonces, #{reads} were checked for corruption and #{corrupt.count {|x| x===true}} were found to be corrupt"

		}
	rescue EOFError
	  puts "End Of File"
	end
end

#check for overlaps
startings.each_with_index { |r,i| 
	startings.each_with_index { |inner_r,inner_i|
		next if r=inner_r
		puts "#{file_names[i]} overlaps with file #{file_names[inner_i]}" if (r..ranges[i]).overlaps?(inner_r..ranges[inner_i])
	}
}

end