site_name := Joss Appleton-Fox
src_dir := src
build_dir := build
dependencies := Makefile $(wildcard templates/* defaults/*)
gh-pages_url := git@github.com:jaf7C7/jaf7c7.github.io.git
gh-pages_initial_commit := 1b955d6715184062cdc51d07632ed3d3ea30bc50
notes_url = git@github.com:jaf7C7/HowTo.git
pandoc := pandoc \
	--standalone \
	--embed-resources \
	--resource-path=src/assets \
  --css styles.css \
	--metadata title-prefix:Joss Appleton-Fox \
  --metadata maxwidth:42em \
  --metadata document-css:true \

default: \
	$(build_dir) \
	$(build_dir)/index.html \
	$(build_dir)/notes \
	$(build_dir)/notes/index.html \
	$(filter-out %/README.md,$(wildcard $(src_dir)/notes/*.md))

$(build_dir):
	git clone $(gh-pages_url) $@
	git -C $(build_dir) reset --hard $(gh-pages_initial_commit)

$(build_dir)/%.html: $(build_dir/%.md) $(dependencies)
	$(pandoc) --output=$@ $<

$(build_dir)/notes/index.html: templates/notes_toc.html $(dependencies)
	test -d $(dir $@) || mkdir $(dir $@)
	$(pandoc) \
		--variable=is_index:true \
		--output=$@/index.html \
		$</README.md

templates/notes_toc.html: $(src_dir)/notes
	test -d $(dir $@) || mkdir $(dir $@)
	pandoc \
		--toc=true \
		--toc-depth=1 \
		--output=$@ \
		$(filter-out %/README.md,$(wildcard $</*.md))

$(src_dir)/notes:
	git clone $(notes_url) $@

serve:
	gnome-terminal --tab -- \
		browser-sync start --server $(build_dir) --files $(build_dir)

publish:
	git -C $(build_dir) add .
	git -C $(build_dir) commit -m "New build: $$(date)"
	git -C $(build_dir) push -f

clean:
	git -C $(build_dir) reset --hard $(gh-pages_initial_commit)
	git -C $(build_dir) clean -dfx
	rm -rf $(src_dir)/notes
