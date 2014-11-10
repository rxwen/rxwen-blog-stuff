all: ppt

img:
	dot -o history.png -Tpng history.dot
	dot -o architecture.png -Tpng architecture.dot
	dot -o architecture_2.png -Tpng architecture_2.dot

ppt: img
	xelatex -interaction=nonstopmode *.tex
