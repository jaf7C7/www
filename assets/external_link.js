document.querySelectorAll('a[href^="http"]').forEach((e) => {
  e.classList.add("external_link");
  e.setAttribute('target', '_blank');
});
