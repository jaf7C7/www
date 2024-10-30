site_name := Joss Appleton-Fox
build := build
assets := assets
notes := notes
notes_url := git@github.com:jaf7C7/HowTo.git
template := template.html
style := style.css
dependencies := $(template) $(style) $(addprefix $(build)/,$(wildcard $(assets)/*))
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

default: \
  $(build) \
  $(build)/index.html \
  $(build)/$(notes)/index.html \
  $(filter-out %/README.md,$(wildcard $(notes)/*.md))
	@echo 'Done.'

$(build):
	git clone $(gh-pages_url) $@
	git -C $(build) reset --hard $(gh-pages_initial_commit)

$(build)/index.html: index.md $(dependencies)
	$(pandoc) --output=$@ $<

$(build)/$(notes)/index.html: $(notes)/README.md $(dependencies)
	exec >$(notes)/toc.yaml ; \
	echo 'toc:' ; \
	for file in $(filter-out %/README.md,$(wildcard $(notes)/*.md)) ; do \
		echo "- title: $$(sed -n '1s/. *//p' $$file)" ; \
		echo "  url: /$${file}.html" ; \
	done
	test -d $(dir $@) || mkdir $(dir $@)
	$(pandoc) \
		--metadata-file=$(notes)/toc.yaml \
		--output=$@ \
		$(notes)/README.md
	rm $(notes)/toc.yaml

$(build)/$(assets)/%: $(assets)/%
	test -d $@ || mkdir $(dir $@)
	cp $< $@

$(notes)/%:
	test -d $(dir $@) || git clone $(notes_url) $(dir $@)

serve:
	gnome-terminal --tab -- \
		browser-sync start --server $(build) --files $(build)

publish:
	git -C $(build) add .
	git -C $(build) commit -m "New build: $$(date)"
	git -C $(build) push -f

clean:
	git -C $(build) reset --hard $(gh-pages_initial_commit)
	git -C $(build) clean -dfx
	rm -rf notes
