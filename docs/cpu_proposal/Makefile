#document compiler
DOC=1masterdoc
SECTIONS=$(wildcard s-*.tex)

all: $(DOC).pdf

$(DOC).pdf: $(DOC).tex $(SECTIONS)
	pdflatex -shell-escape $(DOC).tex

# view the output file and load the masterfile in vim
edit: $(DOC).pdf
	evince $(DOC).pdf&
	vim $(DOC).tex

clean: 
	rm -f *.aux *.log *.pdf
