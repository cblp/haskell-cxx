slides.pdf: slides.md
	pandoc					\
		--output=$@			\
		--pdf-engine=xelatex		\
		--to=beamer			\
		$^
