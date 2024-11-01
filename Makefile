site_name := Joss Appleton-Fox
src_dir := src
src_files := $(shell find $(src_dir) -name '*.md')
dependencies := Makefile template.html defaults.yaml $(wildcard assets/*)
build_dir := build
gh-pages_url := git@github.com:jaf7C7/jaf7c7.github.io.git
pandoc := pandoc --defaults=defaults.yaml

all: $(build) $(src_files:$(src)/%.md=$(build)/%.html)
	@echo 'Done.'

$(build_dir):
	@git clone $(gh-pages_url) $@
	@git -C $(build_dir) reset --hard $(gh-pages_initial_commit)
	@echo 'Created $@'

$(build_dir)/%.html: $(src_dir)/%.md Makefile $(dependencies)
	@echo 'building... $@'
	@test -d $(dir $@) || mkdir -p $(dir $@)
	@$(pandoc) --output=$@ $<

serve:
	@gnome-terminal --tab -- \
		browser-sync start --server $(build_dir) --files $(build_dir)

publish:
	@git -C $(build_dir) add .
	@git -C $(build_dir) commit -m "New build_dir: $$(date)"
	@git -C $(build_dir) push -f

clean:
	@git -C $(build_dir) clean -fxd . >/dev/null 2>&1
	@git -C $(build_dir) reset --hard \
		$$(git -C $(build_dir) log --format=%H | tail -1) >/dev/null 2>&1
