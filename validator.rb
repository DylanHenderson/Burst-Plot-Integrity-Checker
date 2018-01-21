class String
    # colorization
    def colorize(color_code)
        "\e[#{color_code}m#{self}\e[0m"
    end

    def red
        colorize(31)
    end

    def green
        colorize(32)
    end

    def yellow
        colorize(33)
    end

    def blue
        colorize(34)
    end

    def pink
        colorize(35)
    end

    def light_blue
        colorize(36)
    end
end

ranges = []
startings = []
file_names = []

# how many of the nonces to check. divide by this.
division_factor = 1024

# the number of bytes to check per nonce
bytes_per_nonce = 16

ARGV.each_with_index do|arg,ind|

    # this is pretty ugly, checks for args
    ((division_factor = ARGV[ind+1].to_i) && next) if arg === "--d"
    next if arg.to_i == division_factor


    ((bytes_per_nonce = ARGV[ind+1].to_i) && next) if arg === "--b"
    next if arg.to_i == bytes_per_nonce

    puts "Working with a division factor of #{division_factor}".light_blue
    puts "Working with a bytes checked per nonce of #{bytes_per_nonce}".light_blue

    dir_name = arg
    # For win vs unix paths
    file_path = "\/"
    if Gem.win_platform?
        file_path = "\\"
    end

    Dir.foreach(dir_name) do |file_name_single|
        # Check real files
        next if file_name_single == '.' or file_name_single == '..'
        # Create full path for file name
        file_name = dir_name + file_path + file_name_single
        begin

            size_reason = "File: #{file_name} has a size that would not fit a whole number of nonces. It's possible this just means that the last nonce cannot be read".red

            # check the file exists
            if !File.file?(file_name)
                puts "File #{file_name} does not exist, aborting".red
                abort
            end
            puts "Checking file: #{file_name}".light_blue
            size = File.size?(file_name)

            # Check name matches size
            if match = /_\d*_(\d*)_/.match(file_name)
                stated_nonces = (match.captures[0]).to_i
                nonces_start = /_(\d*)_/.match(file_name).captures[0].to_i
                # TODO error check here too I guess
                startings << nonces_start
                ranges << stated_nonces
                file_names << file_name
                stated_size = stated_nonces*262144
                if stated_size != size
                    puts "File: #{file_name} has a size of #{size} bytes which does not match the name of the file which states it has: #{stated_size}".red
                else
                    puts "File size and size stated in file name match correctly".green
                end
            else
                puts "File name is odd, can't find number of nonces in name".red
            end

            nonces_f = size/262144.0
            nonces = nonces_f.floor

            # only examine a small portion of the nonces to speed things up
            reads = nonces*division_factor
            reads = nonces/division_factor if nonces > division_factor
            nonces > division_factor ? seek_skip = division_factor*262144 : seek_skip = 262144

            # the amount of reads/nonces must be an integer, you cannot have half a nonce
            puts size_reason if nonces_f %1 !=0

            puts "Checking File for corruption"
            #Open the file
            File.open(file_name,"rb") { |f|
                puts "Examining #{reads} nonces out of #{nonces}".light_blue
                corrupt = Array.new(reads)
                # For each nonce, read in all the nonces bytes
                reads.times do |r|
                    print "Examining nonce #{r*division_factor}\r".light_blue
                    # If all the nonces are 0 assume that then the nonce is corrupt, store true if corrupt. Only examine first 16 bytes
                    corrupt[r] = f.read(bytes_per_nonce).unpack("H*")[0] === ('00' * bytes_per_nonce)
                    f.seek((seek_skip)-bytes_per_nonce,IO::SEEK_CUR)
                end
                # Ouput the bytes where the nonce is corrupt
                # TODO: options to concatanate for user
                # corrupt.each_with_index {|c,i| puts ("Corrupt nonce found from bytes:  #{262144*(i)*1024} to #{262144*(i+1)*1024}" ) if c }
                puts "Out of #{nonces} nonces, #{reads} were checked for corruption and #{corrupt.count {|x| x===true}} were found to be corrupt".red

            }
        rescue EOFError
            puts "End Of File".red
        end
    end

end

class Range
    def overlaps?(other)
        cover?(other.first) || other.cover?(first)
    end
end

#TODO: add mode to run without corruption checker
#check for overlaps
puts "Checking for overlaps".light_blue
startings.each_with_index { |r,i|
    startings.each_with_index { |inner_r,inner_i|
        next if i==inner_i
        if (r..(ranges[i]+r)).overlaps?(inner_r..(ranges[inner_i]+inner_r))
            if inner_r > r
                n = -1*(inner_r - ranges[i] - r)
                if n > 0
                    puts "#{file_names[i]} overlaps with file #{file_names[inner_i]}".red
                    puts "#{n} nonces found to be overlapping"
                end
            else
                n = -1*(r - ranges[inner_i] - inner_r)
                if n > 0
                    puts "#{file_names[i]} overlaps with file #{file_names[inner_i]}".red
                    puts "#{n} nonces found to be overlapping" if inner_r < r
                end
            end
        end
    }
}

puts "Check Completed".yellow
