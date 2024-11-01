# www

This repo contains the build system for [jaf7c7.github.io](https://jaf7c7.github.io).

## How To Use

1. Clone the repo
2. Add a project's name to the `projects` variable in `Makefile`, and update
   `src/index.md` to link to the new project.
3. Run `make` to build the site.
4. Run `make serve` to preview the new project.
5. Run `make publish` to push changes to [jaf7c7.github.io](https://jaf7c7.github.io)
