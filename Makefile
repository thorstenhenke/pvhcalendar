.PHONY: all clean
all: calendar.pdf

allgemein.cal:
	curl -sSL -o $@ 'https://www.homburgschule.de/index.php?option=com_jevents&task=icals.export&format=ical&catids=24&years=0&k=8827ceb1220550b0acbd3455be0873b4'

grundschule.cal:
	curl -sSL -o $@ 'https://www.homburgschule.de/index.php?option=com_jevents&task=icals.export&format=ical&catids=29&years=0&k=403732b222d974c500ebae3c44ceda70'

sek1.cal:
	curl -sSL -o $@ 'https://www.homburgschule.de/index.php?option=com_jevents&task=icals.export&format=ical&catids=27&years=0&k=00f133c2777c5b7c9a722347c1a3e275'

sek2.cal:
	curl -sSL -o $@ 'https://www.homburgschule.de/index.php?option=com_jevents&task=icals.export&format=ical&catids=28&years=0&k=8867056f9624ab16903bbc8a06caa65d'

%.tsv: %.cal
	./cal2csv.sh --prefix $* $< > $@

%.filtered.tsv: %.tsv
	gsed -E '/(202[0-4]|2025-0[1-6])/d' $< > $@

calendar.tsv: allgemein.filtered.tsv grundschule.filtered.tsv sek1.filtered.tsv sek2.filtered.tsv
	cat $^ > $@

calendar.md: calendar.tsv
	echo "# PvH Kalendar" > $@
	echo "" >> $@
	echo "| Kategorie | Ereignis | Start | " >> $@
	echo "|:---|:---|:---|:---|" >> $@
	sed 's/|/\\|/g' $< | sed 's/\t/ | /g' | sed 's/^/| /' | sed 's/$$/ |/' >> $@

calendar.pdf: calendar.md
	pandoc $< -o $@ \
		--pdf-engine=pdflatex \
		-V geometry:a4paper \
		-V geometry:margin=2cm \
		-V mainfont="DejaVu Sans" \
		-V documentclass=article

clean:
	rm -f *.cal *.tsv *.md *.pdf
