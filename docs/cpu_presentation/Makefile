#document compiler
DOC=cpu_presentation
SECTIONS=$(wildcard s-*.tex)

all: $(DOC).pdf

.PHONY: $(DOC).pdf clean edit

$(DOC).pdf: $(DOC).tex $(SECTIONS)
	pdflatex -shell-escape $(DOC).tex

# view the output file and load the masterfile in vim
edit: $(DOC).pdf
	evince $(DOC).pdf&
	vim $(DOC).tex

clean: 
	rm -f *.aux *.log *.pdf *.nav *.out *.toc *.snm
