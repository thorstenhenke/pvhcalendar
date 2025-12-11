UNAME_S := $(shell uname -s)
ifeq ($(UNAME_S),Linux)
    SED := sed
else
    SED := gsed
endif

all: allgemein.pdf grundschule.pdf sek1.pdf sek2.pdf

# -- DOWNLOAD --
allgemein.cal:
	curl -sSL -o $@ 'https://www.homburgschule.de/index.php?option=com_jevents&task=icals.export&format=ical&catids=24&years=0&k=8827ceb1220550b0acbd3455be0873b4'

grundschule.cal:
	curl -sSL -o $@ 'https://www.homburgschule.de/index.php?option=com_jevents&task=icals.export&format=ical&catids=29&years=0&k=403732b222d974c500ebae3c44ceda70'

sek1.cal:
	curl -sSL -o $@ 'https://www.homburgschule.de/index.php?option=com_jevents&task=icals.export&format=ical&catids=27&years=0&k=00f133c2777c5b7c9a722347c1a3e275'

sek2.cal:
	curl -sSL -o $@ 'https://www.homburgschule.de/index.php?option=com_jevents&task=icals.export&format=ical&catids=28&years=0&k=8867056f9624ab16903bbc8a06caa65d'

# -- CONVERTION --
%.tsv: %.cal
	./cal2csv.sh $< > $@

# -- FILTER RULES --
%.filtered.tsv: %.tsv
	$(SED) -E '/(202[0-4]|2025-0[1-6])/d' $< > $@


# -- MARKDOWN GENERATION --
%.md: %.filtered.tsv
	@echo "Creating Markdown for $*..."
	@echo "# $* Kalender" > $@
	@echo "" >> $@
	@echo "| Datum | Ereignis |" >> $@
	@echo "|:---|:---|" >> $@
	@$(SED) 's/|/\\|/g' $< | $(SED) 's/\t/ | /g' | $(SED) 's/^/| /' | $(SED) 's/$$/ |/' >> $@

# -- PDF GENERATION --
%.pdf: %.md
	pandoc $< -o $@ \
		--pdf-engine=pdflatex \
		-V geometry:a4paper \
		-V geometry:margin=2cm \
		-V mainfont="DejaVu Sans" \
		-V documentclass=article

clean:
	rm -f *.cal *.tsv *.md *.pdf
