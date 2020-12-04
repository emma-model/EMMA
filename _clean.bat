@echo off


del *.~gm
del *.g00
del *.par
del *.log
del *.lst
del *.lxi
del *.gen
del *.tmp
del *.dat
del *.plt
del *.op*
del *.o1*
del *.txt
del *.ref
del *.gdx

REM del *.gdx
	
move /Y	*.xlsx	"trash"

rd 	/S /Q 225a
rd 	/S /Q 225b
rd 	/S /Q 225c
rd 	/S /Q 225d
rd 	/S /Q 225e
rd 	/S /Q 225f
rd 	/S /Q 225g
rd 	/S /Q 225h
rd 	/S /Q 225i
rd 	/S /Q 225j
rd 	/S /Q 225k
rd 	/S /Q 225l

