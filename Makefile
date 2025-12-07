all: allgemein.filtered.tsv grundschule.filtered.tsv sek1.filtered.tsv sek2.filtered.tsv
	cat $^ > calendar.tsv
	rm $^

allgemein.cal:
	curl -sSL -o $@ 'https://www.homburgschule.de/index.php?option=com_jevents&task=icals.export&format=ical&catids=24&years=0&k=8827ceb1220550b0acbd3455be0873b4'

grundschule.cal:
	curl -sSL -o $@ 'https://www.homburgschule.de/index.php?option=com_jevents&task=icals.export&format=ical&catids=29&years=0&k=403732b222d974c500ebae3c44ceda70'

sek1.cal:
	curl -sSL -o $@ 'https://www.homburgschule.de/index.php?option=com_jevents&task=icals.export&format=ical&catids=27&years=0&k=00f133c2777c5b7c9a722347c1a3e275'

sek2.cal:
	curl -sSL -o $@ 'https://www.homburgschule.de/index.php?option=com_jevents&task=icals.export&format=ical&catids=28&years=0&k=8867056f9624ab16903bbc8a06caa65d'

# Generic conversion rules
%.tsv: %.cal
	./cal2csv.sh --prefix $* $< > $@
	rm $<

%.filtered.tsv: %.tsv
	gsed -E '/(202[0-4]|2025-0[1-6])/d' $< > $@

# ... (existing content) ...

# 1. Convert TSV to Markdown Table
# We use sed to:
#   1. Escape existing pipes in text (to avoid breaking the table)
#   2. Convert tabs to Markdown table delimiters
#   3. Wrap the line in pipes
calendar.md: calendar.tsv
	echo "# PvH Kalendar" > $@
	echo "" >> $@
	echo "| Kategorie | Ereignis | Start | Ende |" >> $@
	echo "|:---|:---|:---|:---|" >> $@
	sed 's/|/\\|/g' $< | sed 's/\t/ | /g' | sed 's/^/| /' | sed 's/$$/ |/' >> $@

# 2. Convert Markdown to PDF
# Requires: pandoc and a pdf-engine (like pdflatex, tectonic, or weasyprint)
calendar.pdf: calendar.md
	pandoc $< -o $@ \
		--pdf-engine=pdflatex \
		-V geometry:a4paper \
		-V geometry:margin=2cm \
		-V mainfont="DejaVu Sans" \
		-V documentclass=article

# Update clean to remove new files
clean:
	rm -f *.cal *.tsv *.md *.pdf
