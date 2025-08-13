// Basic enhancement: mark current nav link and report missing images in console
(function(){
  const here = location.pathname.replace(/\/index\.html$/, '');
  document.querySelectorAll('nav a').forEach(a => {
    const href = a.getAttribute('href');
    if (!href) return;
    const url = new URL(href, location.origin);
    if (url.pathname.replace(/\/index\.html$/, '') === here) {
      a.setAttribute('aria-current', 'page');
    }
  });
  // Simple missing image detector (console warnings)
  document.querySelectorAll('img').forEach(img => {
    img.addEventListener('error', () => {
      console.warn('Missing image:', img.getAttribute('src'), 'on', location.pathname);
    }, { once: true });
  });
})();
