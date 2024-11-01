site_name := Joss Appleton-Fox
projects := image-carousel
src_dir := src
build_dir := build
src_files := $(shell find $(src_dir) -name '*.md')
dependencies := Makefile template.html defaults.yaml $(wildcard assets/*)
gh-pages_url := git@github.com:jaf7C7/jaf7c7.github.io.git
pandoc := pandoc --defaults=defaults.yaml

all: $(build_dir) \
     $(src_files:$(src_dir)/%.md=$(build_dir)/%.html) \
     $(addprefix $(build_dir)/,$(projects))

$(build_dir):
	@git clone $(gh-pages_url) $@
	@git -C $(build_dir) reset --hard $(gh-pages_initial_commit)
	@echo 'Created $@'

$(build_dir)/%.html: $(src_dir)/%.md Makefile $(dependencies)
	@echo 'building... $@'
	@test -d $(dir $@) || mkdir -p $(dir $@)
	@$(pandoc) --output=$@ $<

$(build_dir)/%:
	@echo 'building... $@'
	@git -C $(build_dir) clone \
		"git@github.com:jaf7C7/$(notdir $(basename $@)).git" >/dev/null 2>&1
	@rm -rf $@/.git

serve:
	@gnome-terminal --tab -- \
		browser-sync start --server $(build_dir) --files $(build_dir)

publish:
	@git -C $(build_dir) add .
	@git -C $(build_dir) commit -m "New build: $$(date)"
	@git -C $(build_dir) push -f

clean:
	@exec >/dev/null 2>&1 ; \
	git -C $(build_dir) reset --hard \
		$$(git -C $(build_dir) log --format=%H | tail -1) ; \
	git -C $(build_dir) clean -fxd . ; \
	rm -rf $(addprefix $(build_dir)/,$(projects))
