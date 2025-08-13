(function () {
  var isGh = /\.github\.io$/i.test(location.hostname);
  var parts = location.pathname.split('/').filter(Boolean);
  var prefix = isGh ? (parts.length ? '/' + parts[0] + '/' : '/') : '/';

  function inSite(url) {
    return !url || url.startsWith('#') ||
           /^mailto:|^tel:/i.test(url) || /^\/\//.test(url);
  }

  function normalize(attr) {
    document.querySelectorAll('[' + attr + ']').forEach(function (el) {
      var v = el.getAttribute(attr);
      if (!v) return;

      // Rewrite old links to other repos on your GH pages back into THIS site
      var m = v.match(/^https?:\/\/otiseduncan\.github\.io\/([^/]+)\/(.*)$/i);
      if (m) { el.setAttribute(attr, prefix + m[2].replace(/^\//,'')); return; }

      // Skip anchors/mailto/tel/protocol-relative and absolute http(s)
      if (inSite(v) || /^https?:\/\//i.test(v)) return;

      // If already root-absolute -> add GH repo prefix (online)
      if (v.startsWith('/')) { el.setAttribute(attr, prefix + v.replace(/^\//,'')); return; }

      // Otherwise it's relative ("_assets/...", "menu/", "./...", "../..."):
      // Convert to root-absolute by stripping leading ./ or ../ and prefixing with "/"
      var normalized = v.replace(/^(\.\/)+/, '').replace(/^(\.\.\/)+/, '');
      el.setAttribute(attr, prefix + normalized.replace(/^\//,''));
    });
  }

  normalize('href');     // <a>, <link>
  normalize('src');      // <img>, <script>
})();
