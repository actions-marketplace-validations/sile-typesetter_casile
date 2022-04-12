ZOLAS := $(call pattern_list,$(SOURCES),.zola)

# Unlike most other rules, the zola site stuff doesn't depend on much being generated, it mostly looks what *has been* generated and goes from there
list_extant_resources = $(filter $1%,$(filter-out $1.zola,$(wildcard $(DISTFILES) $(DISTDIRS))))

$(ZOLAS): %.zola: $(addprefix $(BUILDDIR)/%.zola/,config.toml content/_index.md sass/style.sass) %-epub-$(_poster).jpg | $$(call list_extant_resources,$$*) $(BUILDDIR)
	local resourcedir="$(<D)/static"
	rm -rf "$$resourcedir"
	mkdir -p "$$resourcedir"
	$(and $(filter $*%,$^ $|),cp -a $(filter $*%,$^ $|) "$$resourcedir")
	$(and $(filter $*.mdbook,$^ $|),mv $$resourcedir/$*.mdbook $$resourcedir/$(_read))
	rm -rf $@
	$(ZOLA) -r "$(<D)" build -o "$@"

DISTDIRS += $(ZOLAS)

$(BUILDDIR)/%.zola/content/manifest.json: $(BUILDDIR)/%-manifest.json | $(BUILDDIR)
	install -Dm600 $< $@

$(BUILDDIR)/%.zola/content/_index.md: $(BUILDDIR)/%.zola/content/manifest.json %-epub-$(_poster).jpg $(BUILDDIR)/%.zola/templates/book.html | $$(call list_extant_resources,$$*) $(BUILDDIR)
	mkdir -p $(@D)
	$(ZSH) << 'EOF' # inception to break out of CaSILE’s make shell wrapper
	exec > $@ # grey magic to capture output
	cat << FRONTMATTER
	+++
	template = "$(notdir $(lastword $^))"
	[extra]
	coverimg = "$(firstword $(filter $(call pattern_list,$*,$(LAYOUTS),-$(_3d)-$(_front).png),$^ $|) $*-epub-$(_poster).jpg)"
	+++
	FRONTMATTER
	$(and $(filter $*.mdbook,$^ $|),echo "- [Online oku]($(_read))")
	$(and $(filter $*.epub,$^ $|),echo "- EPUB olarak indir: [epub]($*.epub)")
	$(and $(filter $*.mobi,$^ $|),echo "- MOBI olarak indir: [mobi]($*.mobi)")
	for pdf in $(filter $(call pattern_list,$*,$(LAYOUTS),.pdf),$^ $|); do
		echo "- PDF olarak indir: [$${$${pdf$(hash)$*-}%.pdf}]($$pdf)"
	done
	EOF

$(BUILDDIR)/%.zola/templates/series.html: $(ZOLA_TEMPLATE_SERIES) $(ZOLA_STYLE) | $(BUILDDIR)
	install -Dm600 $< $@

$(BUILDDIR)/%.zola/templates/book.html: $(ZOLA_TEMPLATE_BOOK) $(ZOLA_STYLE) | $(BUILDDIR)
	install -Dm600 $< $@

$(BUILDDIR)/%.zola/sass/style.sass: $(ZOLA_STYLE) | $(BUILDDIR)
	install -Dm600 $< $@

$(BUILDDIR)/%.zola/config.toml: %-manifest.yml | $(BUILDDIR)
	mkdir -p $(@D)
	$(YQ) -t '{
			"title": .title,
			"base_url": "$(call urlinfo,$*)",
			"compile_sass": true
		}' $< > $@

