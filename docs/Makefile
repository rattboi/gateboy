# This makefile can be used to build all of the LaTeX documents under
# the doc directory. To add a new document, create a folder (must not
# contain spaces in name) for the files, and make sure there is a
# makefile in the subdirectory that supports both make and clean
# targets. Then add the name of the folder to the 'DOCS' line.


DOCS=$(shell find * -type d)

clean_DOCS=$(addprefix clean_,$(DOCS))


all: $(DOCS)
clean: $(clean_DOCS)

.PHONY: $(DOCS) $(clean_DOCS)

$(DOCS):
	$(MAKE) -C $@ 

$(clean_DOCS):
	- $(MAKE) -C $(patsubst clean_%,%,$@) clean


