# LaraperlTrans 

### Convert and manipulate Laravel's translation family of functions

* run: perl -Ilib/ main.pl [--overwrite, --generate-json]

Default behavior of laraperl-trans is to perform simulation and print what would 
be substituted on the STDOUT. When --overwrite flag is set, lines with 
substitution strings are written to original files. It's recommended to always 
first perform simulation before actual writing to files.


PARAMETERS:

--overwrite		perform substitution directly on the file
--generate-json		create lang JSON file which will be populated with all 
			translation strings 

