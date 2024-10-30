site_name := Joss Appleton-Fox
build := build
assets := assets
notes := notes
notes_url := git@github.com:jaf7C7/HowTo.git
template := template.html
style := style.css
# XXX Is this necessary?
# dependencies := $(template) $(style) $(build) $(addprefix $(build)/,$(wildcard $(assets)/*))
gh-pages_url := git@github.com:jaf7C7/jaf7c7.github.io.git
gh-pages_initial_commit := 1b955d6715184062cdc51d07632ed3d3ea30bc50
pandoc := pandoc \
	--standalone \
	--template='$(template)' \
	--embed-resources \
	--resource-path='.:$(assets)' \
	--css='$(style)' \
	--metadata=title-prefix:'$(site_name)' \
	--metadata=maxwidth:42em \
	--metadata=document-css:true

all: $(build) $(notes)
	${MAKE} \
		$(build)/index.html \
		$(build)/$(notes)/index.html \
		$(patsubst %.md,$(build)/%.html,$(filter-out %/README.md,$(wildcard $(notes)/*.md)))
	@tree

$(build):
	@git clone $(gh-pages_url) $@
	@git -C $(build) reset --hard $(gh-pages_initial_commit)
	@echo 'Created $@'

$(build)/%.html: %.md
	@echo '$@'
	$(pandoc) --output=$@ $<

$(notes):
	@test -d $@ || git clone $(notes_url) $@
	# Turn each document's heading into a pandoc title block:
	@for file in $@/*.md ; do \
		sed -i '1s/#/%/' "$$file" ; \
	done
	@echo 'Created $@'

$(build)/$(notes)/index.html:
	@exec >$(notes)/toc.yaml ; \
	echo 'title: "$(notes)"' ; \
	echo 'toc:' ; \
	for file in $(filter-out %/README.md,$(wildcard $(notes)/*.md)) ; do \
		echo "- title: $$(sed -n '1s/. *//p' "$$file")" ; \
		echo "  url: /$${file%.md}.html" ; \
	done
	@test -d $(dir $@) || mkdir $(dir $@)
	@$(pandoc) \
		--metadata-file=$(notes)/toc.yaml \
		--output=$@ \
		$(notes)/README.md
	@rm $(notes)/toc.yaml
	@echo 'Created $@'

serve:
	@gnome-terminal --tab -- \
		browser-sync start --server $(build) --files $(build)

publish:
	@git -C $(build) add .
	@git -C $(build) commit -m "New build: $$(date)"
	@git -C $(build) push -f

clean:
	@git -C $(build) reset --hard $(gh-pages_initial_commit)
	@git -C $(build) clean -dfx
	@rm -rf notes
	@echo 'Cleaning finished.'
