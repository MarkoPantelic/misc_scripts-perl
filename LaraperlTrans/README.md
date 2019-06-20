# LaraperlTrans 

### Convert and manipulate Laravel's translation family of functions

* run: perl -Ilib/ main.pl --process-dirs-paths=STRING --lang-dir-path[(STRING1,..STRINGn)
       [--overwrite, --generate-json]

Default behavior of laraperl-trans is to perform simulation and print what would 
be substituted on the STDOUT. When --overwrite flag is set, lines with 
substitution strings are written to original files. It's recommended to always 
first perform simulation before actual writing to files.


PARAMETERS:

--process-dirs-paths	comma separated list of directories whose files are to
			be processed	
--lang-dir-path		path of lang directory 
--overwrite		perform substitution in-place on all files
--generate-json		create lang JSON file which will be populated with all 
			translation strings 

