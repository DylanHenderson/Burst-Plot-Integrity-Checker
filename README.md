# Burst-Plot-Integrity-Checker
A simple Ruby script that does some funky tests to see if your burst plot is good to mine

## What it does
* Checks that plots do not have unwritten/empty nonces
* Checks that plots do not overlap
* Checks that plots' names match file size
* Checks that plots have a whole number of nonces

## How to use
* Make sure you have Ruby installed (Windows: https://rubyinstaller.org/)
* Open a terminal/Cmd and navigate to the validator: example: cd C:\Users\FooUser\Documents\burstcoin\Burst-Plot-Integrity-Checker
* run ruby validator.rb <PlotFolderLocations> example: ruby validator.rb D:plots F:plots2

## Customize corruption checker
### --d <1 to 10000> 
division factor. 
This is what the total nonce count is divided by. 1 would mean all the nonces.
Increase this number the larger the file.
#### Recomendations
	--d 1024 for 500GB-1TB sized plot files
#### Default
	1024

### --b <1 to 262144> 
bytes checked per nonce. 
This is the number of bytes checked per nonce. There are 262144 bytes per nonce.
#### Recomendations
	--b 16 for 500GB-1TB sized plot files
#### Default
	16

## How long does it take?
* Not very long, it analyses a subset of the nounces. Maybe 1 min per TB
* This is much slower than it could be though. Ruby's File.Seek and File.Read seem to be the problem here.

## Known Issues
* In windows clicking on the terminal pauses the counting, pressing any key resumes. Weird..
* Overlapping files show twice

## Donations
If you have some free Burst to give here's my address: BURST-4P7H-83WU-NNBB-H3YVS :)
