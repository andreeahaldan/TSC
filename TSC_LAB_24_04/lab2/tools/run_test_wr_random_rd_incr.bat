::========================================================================================
call clean.bat
::========================================================================================
call build.bat
::========================================================================================
cd ../sim
vsim -c -do "do run.do 10 2 7777"
