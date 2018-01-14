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
* run ruby validator.rb <PlotFolderLocation> example: ruby validator.rb D:plots

## How long does it take?
* Not very long, it analyses a subset of the nounces. Maybe 1 min per TB

## Known Issues
* In windows clicking on the terminal pauses the counting, pressing any key resumes. Weird..
* Overlapping files show twice

## Donations
If you have some free Burst to give here's my address: BURST-4P7H-83WU-NNBB-H3YVS :)
