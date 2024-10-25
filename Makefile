site_name = Joss Appleton-Fox
src_dir = src
build_dir = build
gh-pages_url = git@github.com:jaf7C7/jaf7c7.github.io.git
gh-pages_initial_commit = 1b955d6715184062cdc51d07632ed3d3ea30bc50
resource_dir = resources
template_file = template.html
resource_files = $(wildcard $(resource_dir)/*)
config_files = Makefile $(template_file)
global_dependencies = $(resource_files) $(config_files)

define get_title =
$(shell sed -e '1s/\# *//' -e '1s/'\''/&\\&&/g' -e '1!d' $<)
endef

pandoc = pandoc \
				 --from markdown \
				 --to html \
				 --template '$(template_file)' \
				 --shift-heading-level-by 1 \
				 --title-prefix='$(site_name)' \
				 --metadata title='$(get_title)'

all: $(build_dir) $(build_dir)/index.html

$(build_dir):
	test -d $@ || git clone $(gh-pages_url) $@
	git -C $@ reset --hard $(gh-pages_initial_commit)

$(build_dir)/%.html: $(src_dir)/%.md $(global_dependencies)
	cp -r $(resource_files) $(build_dir)/
	$(pandoc) --output $@ $<

serve:
	browser-sync start --server $(build_dir) --files $(build_dir)

publish: all
	git -C $(build_dir) add .
	git -C $(build_dir) commit -m 'New build: $(shell date)'
	git -C $(build_dir) push -f

clean:
	rm -rf $(build_dir)
