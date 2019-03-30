slides.html: slides.md
	pandoc	--output=$@	\
		--standalone	\
		--to=revealjs	\
		$^
