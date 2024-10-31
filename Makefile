site_name := Joss Appleton-Fox
src := src
src_files := $(shell find $(src) -name '*.md')
assets := $(shell find assets/ -type f)
build := build
gh-pages_url := git@github.com:jaf7C7/jaf7c7.github.io.git
pandoc := pandoc --defaults=defaults.yaml

all: $(build) $(src_files:$(src)/%.md=$(build)/%.html)
	@echo 'Done.'

$(build):
	@git clone $(gh-pages_url) $@
	@git -C $(build) reset --hard $(gh-pages_initial_commit)
	@echo 'Created $@'

$(build)/%.html: $(src)/%.md Makefile $(assets)
	@echo '$@'
	@test -d $(dir $@) || mkdir -p $(dir $@)
	@$(pandoc) --output=$@ $<

serve:
	@gnome-terminal --tab -- \
		browser-sync start --server $(build) --files $(build)

publish:
	@git -C $(build) add .
	@git -C $(build) commit -m "New build: $$(date)"
	@git -C $(build) push -f

clean:
	@git -C $(build) reset --hard $$(git -C $(build) log --format=%H | tail -1)
	@git -C $(build) clean -dfx
	@echo 'Cleaning finished.'
