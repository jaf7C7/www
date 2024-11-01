/*
 * Mark all http links which don't go to github as external links.
 */
document.querySelectorAll('a[href^="http"]:not(a[href~github])').forEach((e) => {
  e.classList.add("external_link");
  e.setAttribute('target', '_blank');
});
