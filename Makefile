.PHONY: help list all clean

help:
	@echo "Usage: make [target]"
	@echo "Targets:"
	@echo "  <file> - Build a single pdf file."
	@echo "  list   - List available pdf targets."
	@echo "  all    - Build all pdf files."
	@echo "  clean  - Clean all pdf files."
	@echo "  help   - Print this help message."

list:
	@echo "$(patsubst %.tex,%.pdf,$(wildcard *.tex))"

all: $(patsubst %.tex,%.pdf,$(wildcard *.tex))

clean:
	-@latexmk -C 1>/dev/null

ass3.pdf: ass3.tex CompilerAssignment.cls
	latexmk -pdf -pdflatex="xelatex -interaction=nonstopmode" ass3.tex 1>/dev/null
	-@latexmk -c ass3.tex 1>/dev/null

%.pdf: %.tex CompilerAssignment.cls
	latexmk -pdf -pdflatex="pdflatex -interaction=nonstopmode" $< 1>/dev/null
	-@latexmk -c $< 1>/dev/null