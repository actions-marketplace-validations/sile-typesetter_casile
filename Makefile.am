$(and $(word 2,$(MAKEFILE_LIST)),$(error This is not the makefile you should include in your project to run SILE, please use 'rules' instead.))

_casile = $(shell sed -e "$(program_transform_name)" <<< casile)

licensedir = $(datarootdir)/licenses/$(_casile)
docdir = $(datarootdir)/doc/$(_casile)
datadir = $(datarootdir)/$(_casile)

dist_doc_DATA = README.md CHANGELOG.md
dist_license_DATA = LICENSE.txt

EXTRA_DIST = package.json yarn.lock Dockerfile build-aux/docker-entrypoint.sh

bin_PROGRAMS = casile

_casile_libs = src/lib.rs src/i18n.rs
_casile_modules = src/make/mod.rs src/setup/mod.rs src/shell/mod.rs
_casile_assets = assets/en-US/cli.ftl assets/tr-TR/cli.ftl
casile_SOURCES = Cargo.toml build.rs src/main.rs $(_casile_libs) $(_casile_modules) $(_casile_assets)
EXTRA_casile_SOURCES = Cargo.lock tests/cli.rs

# use :read !git ls-files <pattern> to repopulate <pattern>_DATA vars

rulesdir = $(datadir)
dist_rules_DATA = rules rules-functions rules-en rules-tr

luadir = $(datadir)
dist_lua_DATA = block_styles.lua cabook.lua casile.lua covers.lua endnotes.lua hyphenation_exceptions.lua imprint.lua inline_styles.lua lists.lua readmeta.lua

povdir = $(datadir)
dist_pov_DATA = back.pov book.pov front.pov montage.pov pile.pov

xmldir = $(datadir)
dist_xml_DATA = binding.xml cover.xml geometry.xml

sildir = $(datadir)
dist_sil_DATA = a5kesme.sil template.sil

svgdir = $(datadir)
dist_svg_DATA = binding.svg emblum.svg logo.svg

m4dir = $(datadir)
dist_m4_DATA = casile.m4

yamldir = $(datadir)
dist_yaml_DATA = casile.yml

templatesdir = $(datadir)
dist_templates_DATA = editorconfig gitignore gitlab-ci.yml

namesdir = $(datadir)
dist_names_DATA = names.en.txt names.la.txt names.part.txt names.tr.txt names.und.txt names.xx.txt

seddir = $(datadir)
dist_sed_DATA = upgrade-lua.sed upgrade-make.sed upgrade-markdown.sed upgrade-yaml.sed

vimdir = $(datadir)
dist_vim_DATA = citation_audit.vim quotation_audit.vim

scriptsdir = $(datadir)/bin
dist_scripts_DATA = bin/branch2criticmark.zsh bin/cover_title.py bin/diff2marked.zsh bin/extract_references.js bin/figure_dash.pl bin/functions.zsh bin/isbn_format.py bin/italic_reorder.pl bin/lazy_quotes.pl bin/link_verses.js bin/loadchapters.zsh bin/msword_escapes.pl bin/normalize_references.js bin/ordinal_spaces.pl bin/renumber_footnotes.pl bin/reorder_punctuation.pl bin/series_sort.lua bin/smart_quotes.pl bin/split_chapters.zsh bin/stats.zsh bin/toc2breaks.lua bin/unicode_symbols.pl bin/worklog.zsh

fontsdir = $(datadir)/fonts
dist_fonts_DATA = fonts/Almendra-Bold.otf fonts/Almendra-BoldItalic.otf fonts/Almendra-Italic.otf fonts/Almendra-Regular.otf fonts/AlmendraDisplay-Regular.otf fonts/AlmendraSC-Bold.otf fonts/AlmendraSC-BoldItalic.otf fonts/AlmendraSC-Italic.otf fonts/AlmendraSC-Regular.otf fonts/FeFlow2.otf fonts/NexaRustExtras-Free.otf fonts/NexaRustHandmade-Extended-Free.otf fonts/NexaRustSans-Black-Free.otf fonts/NexaRustScriptL-0-Free.otf fonts/NexaRustSlab-BlackShadow01-Free.otf fonts/Nymphette.ttf fonts/PrintersOrnamentsOne.ttf

filtersdir = $(datadir)/pandoc-filters
dist_filters_DATA = pandoc-filters/chapterid.lua pandoc-filters/epubclean.lua pandoc-filters/svg2pdf.py pandoc-filters/withoutfootnotes.lua pandoc-filters/withoutheadinglinks.lua pandoc-filters/withoutlinks.lua pandoc-filters/withverses.lua

packagesdir = $(datadir)/packages
dist_packages_DATA = packages/crop.lua packages/markdown.lua packages/verseindex.lua

layoutsdir = $(datadir)/layouts
dist_layouts_DATA = layouts/a4.lua layouts/a4ciltli.lua layouts/a5trim.lua layouts/a6.lua layouts/a6trim.lua layouts/a7.lua layouts/a7kart.lua layouts/a7trimkart.lua layouts/app.lua layouts/banner.lua layouts/businesscard.lua layouts/cep.lua layouts/ekran.lua layouts/epub.lua layouts/halfletter.lua layouts/octavo.lua layouts/royaloctavo.lua layouts/square.lua layouts/wide.lua

assetsdir = $(datadir)/assets
dist_assets_DATA =

if ENABLE_BASH_COMPLETION
bashcompletiondir = $(BASH_COMPLETION_DIR)
dist_bashcompletion_DATA = $(COMPLETIONS_OUT_DIR)/$(_casile)
endif

if ENABLE_FISH_COMPLETION
fishcompletiondir = $(FISH_COMPLETION_DIR)
dist_fishcompletion_DATA = $(COMPLETIONS_OUT_DIR)/$(_casile).fish
endif

if ENABLE_ZSH_COMPLETION
zshcompletiondir = $(ZSH_COMPLETION_DIR)
dist_zshcompletion_DATA = $(COMPLETIONS_OUT_DIR)/_$(_casile)
endif

if DEBUG_RELEASE
CARGO_RELEASE_ARGS=
else
CARGO_RELEASE_ARGS=--release --locked --all-features
endif

CARGO_VERBOSE = $(cargo_verbose_$(V))
cargo_verbose_ = $(cargo_verbose_$(AM_DEFAULT_VERBOSITY))
cargo_verbose_0 =
cargo_verbose_1 = --verbose

CARGO_TARGET = target/release/casile
COMPLETIONS_OUT_DIR = target/release/completions

casile$(EXEEXT): $(CARGO_TARGET)
	cp -bf $< $@

$(COMPLETIONS_OUT_DIR)/$(_casile): $(CARGO_TARGET)
	cp -bf $(COMPLETIONS_OUT_DIR)/casile.bash $@

$(COMPLETIONS_OUT_DIR)/$(_casile).elv: $(CARGO_TARGET)
	cp -bf $(COMPLETIONS_OUT_DIR)/casile.elv $@

$(COMPLETIONS_OUT_DIR)/$(_casile).fish: $(CARGO_TARGET)
	cp -bf $(COMPLETIONS_OUT_DIR)/casile.fish $@

$(COMPLETIONS_OUT_DIR)/_$(_casile).ps1: $(CARGO_TARGET)
	cp -bf $(COMPLETIONS_OUT_DIR)/_casile.ps1 $@

$(COMPLETIONS_OUT_DIR)/_$(_casile): $(CARGO_TARGET)
	cp -bf $(COMPLETIONS_OUT_DIR)/_casile $@

$(CARGO_TARGET): $(casile_SOURCES) clean-embedded-assets
	cargo build $(CARGO_VERBOSE) $(CARGO_RELEASE_ARGS)

.PHONY: clean-embedded-assets
clean-embedded-assets:
	[[ -d .git  ]] || exit 0
	git clean -dxf assets

all: init

.PHONY:
init: node_modules

node_modules: yarn.lock
	yarn install --frozen-lockfile

yarn.lock: package.json
	yarn install

dist-hook:
	yarn install --production --frozen-lockfile --modules-folder "$(distdir)/node_modules"

install-data-hook:
	yarn install --production --frozen-lockfile --modules-folder "$(DESTDIR)$(datadir)/node_modules"

uninstall-hook:
	rm -rf "$(DESTDIR)$(datadir)/node_modules"

RELTYPE ?=

.PHONY: tagrelease
tagrelease:
	test -z $$(git tag --points-at HEAD) || exit 0 # end if we are already on a release tag
	git diff-index --quiet --cached HEAD || exit 1 # die if anything staged but not committed
	git diff-files --quiet || exit 1 # die if any tracked files have unstagged changes
	yarn run release $(and $(RELTYPE),--release-as $(RELTYPE))

.PHONY: release
release: tagrelease

.PHONY: docker
docker: Dockerfile build-aux/docker-entrypoint.sh
	docker build \
		--build-arg VCS_REF="$(VERSION)" \
		--tag siletypesetter/casile:HEAD \
		./

check-local: $(casile_SOURCES) $(EXTRA_casile_SOURCES)
	cargo test --locked

clean-local:
	cargo clean