#document compiler
DOC=1masterdoc

all: $(DOC).pdf


%.pdf: %.tex
	pdflatex -shell-escape $^

# view the output file and load the masterfile in vim
edit: $(DOC).pdf
	evince $(DOC).pdf&
	vim $(DOC).tex

clean: 
	rm -f *.aux *.log *.pdf
