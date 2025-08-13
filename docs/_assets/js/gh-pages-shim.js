(function () {
  if (!/\.github\.io$/.test(location.hostname)) return; // only on GH Pages project sites

  var parts = location.pathname.split('/').filter(Boolean);
  var prefix = parts.length ? '/' + parts[0] + '/' : '/';

  function fix(attr) {
    document.querySelectorAll('[' + attr + '^="/"]').forEach(function (el) {
      var val = el.getAttribute(attr);
      if (!val || /^\/\//.test(val)) return; // skip protocol-relative
      el.setAttribute(attr, prefix + val.replace(/^\//, ''));
    });
  }

  fix('href');  // <a>, <link>
  fix('src');   // <img>, <script>
})();
