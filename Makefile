instdir = /CD1/suse/setup/slide

fname = slideshow
srcdir=.

potfile=po/$(fname).pot
pofiles=po/en.po $(wildcard po/*.po)
langs = $(notdir $(pofiles:.po=))
# list of languages ready for distribution _and_ installation
dist_langs = $(langs)
# take the files from txt/LL/*.rtf
# txt/*/*.rtf does not work. you get a dir called "txt/*"!
dist_lang_files = $(addprefix txt/,$(addsuffix /*.rtf,$(dist_langs)))

EXTRA_DIST =					\
	$(fname).xml $(xsl_styles)		\
	$(pofiles)				\
	pic/*.png				\
	$(dist_lang_files)

xml = $(addsuffix .xml,$(langs))
rtf = $(xml:.xml=.rtf)
valid = $(xml:.xml=.valid)
xsl_styles = $(fname).xsl

SUFFIXES = .xml .rtf .valid .po .pot

XSLTPROC = xsltproc
XMLLINT = xmllint
XML2PO = xml2po

MSGMERGE_UPDATE = msgmerge --update

all: validate rtf

txt:
	mkdir txt

rtf: $(rtf)
%.rtf: %.xml | txt
	ll=$(basename $<); \
	  rm -rf txt/$$ll ; \
	  mkdir txt/$$ll ; \
	  $(XSLTPROC) --nonet --stringparam out.dir "txt/$$ll" \
	    $(xsl_styles) $< 1>/dev/null; \
          for f in txt/$$ll/*.rtf ; do \
	    sed -i 's/\/>/>/;s/%imagedir%/\&imagedir;/' $$f; \
	  done ; \
	  cat txt/$$ll/*.rtf > $@; \
	  iconv --from utf-8 --to utf-8 $@ > /dev/null || { echo "$@ not utf8"; exit 1; };


validate: $(valid)
%.valid: %.xml
	$(XMLLINT) --nonet --valid --noout $< && touch $@

pot: $(potfile)
$(potfile): $(fname).xml
	$(XMLLINT) --nonet --valid --noout $(fname).xml
	$(XML2PO) --expand-all-entities -o $(potfile) $(fname).xml

# re-merge po translation files
po: $(pofiles)
$(pofiles): $(potfile)
	@lang=`echo $@ | sed -e 's,.*/,,' -e 's/\.po$$//'`; \
	echo "$(MSGMERGE_UPDATE) po/$${lang}.po $(potfile)"; \
	if [ $${lang} = en ]; then \
	  msgen -o po/$${lang}.po $(potfile) ;\
	else $(MSGMERGE_UPDATE) po/$${lang}.po $(potfile) ; fi

xml: $(xml)
%.xml: po/%.po
	@lang=`echo $@ | sed -e 's,.*/,,' -e 's,$(fname)_/,,' -e 's/\.xml$$//'`; \
	echo "$(XML2PO) -p po/$${lang}.po -o $${lang}.xml $(potfile)"; \
	$(XML2PO) -p po/$${lang}.po -o $${lang}.xml $(fname).xml

# rndir=$(DESTDIR)$(datadir)/doc/$(PACKAGE_NAME)
install:
#	$(mkinstalldirs) $(rndir)
#	for file in $(html); do \
#	  $(INSTALL_DATA) $$file $(rndir) ; \
#	done
	mkdir -p $(DESTDIR)/$(instdir)
	-test -d $(srcdir)/txt && cp -a $(srcdir)/txt $(DESTDIR)/$(instdir)
	-test -d $(srcdir)/pic && cp -a $(srcdir)/pic $(DESTDIR)/$(instdir)

stats:
	@for i in $(pofiles); do echo -n "$$i: ";  msgfmt --statistics -o /dev/null $$i 2>&1; done | sort -k2 -n

clean:
	rm -f $(rtf) $(valid) $(xml) po/*~

really-clean: clean
	rm -rf txt

.PHONY: clean really-clean xml rtf po all validate stats
