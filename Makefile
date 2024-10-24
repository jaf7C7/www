site_name = Joss Appleton-Fox
src_dir = src
build_dir = build
gh-pages_url = git@github.com:jaf7C7/jaf7c7.github.io.git
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

all: $(build_dir)/index.html

$(build_dir)/%.html: $(src_dir)/%.md $(global_dependencies)
	test -d $(dir $@) || mkdir $(dir $@)
	cp -r $(resource_files) $(build_dir)/
	$(pandoc) --output $@ $<

serve:
	browser-sync start --server $(build_dir) --files $(build_dir)

# TODO: Finish this:
# https://docs.github.com/en/actions/writing-workflows
publish: all
	echo 'TODO: How to push just the build files to the gh-pages repo?'

clean:
	rm -rf $(build_dir)
