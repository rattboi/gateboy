#document compiler

all: 1masterdoc.pdf


%.pdf: %.tex
	pdflatex -shell-escape $^


clean: 
	rm -f *.aux *.log *.pdf
