#!/bin/bash
# Generates /docs/<slug>/index.html for each markdown doc file.
# Uses the doc.html template and inlines the markdown content for client-side rendering.

set -e

DOCS_DIR="docs"
TEMPLATE_HEAD='<!DOCTYPE html>
<html lang="en" class="scroll-smooth">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>__TITLE__ — Winn Docs</title>
  <script src="https://cdn.tailwindcss.com"></script>
  <script>
    tailwind.config = {
      theme: {
        extend: {
          colors: {
            winn: {
              50: "#f0f4ff", 100: "#dbe4ff", 200: "#bac8ff", 300: "#91a7ff",
              400: "#748ffc", 500: "#5c7cfa", 600: "#4c6ef5", 700: "#4263eb",
              800: "#3b5bdb", 900: "#364fc7", 950: "#1e2a5e",
            },
          },
          fontFamily: {
            sans: ["Inter", "system-ui", "-apple-system", "sans-serif"],
            mono: ["JetBrains Mono", "Fira Code", "monospace"],
          },
        },
      },
    }
  </script>
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800;900&family=JetBrains+Mono:wght@400;500&display=swap" rel="stylesheet">
  <link href="/css/custom.css" rel="stylesheet">
  <link href="/css/docs.css" rel="stylesheet">
  <script src="https://cdn.jsdelivr.net/npm/marked/marked.min.js"></script>
  <link href="https://cdn.jsdelivr.net/npm/prismjs@1.29.0/themes/prism-tomorrow.min.css" rel="stylesheet">
  <link href="/css/prism-winn.css" rel="stylesheet">
  <script src="https://cdn.jsdelivr.net/npm/prismjs@1.29.0/prism.min.js"></script>
  <script src="https://cdn.jsdelivr.net/npm/prismjs@1.29.0/components/prism-bash.min.js"></script>
  <script src="https://cdn.jsdelivr.net/npm/prismjs@1.29.0/components/prism-json.min.js"></script>
  <script src="https://cdn.jsdelivr.net/npm/prismjs@1.29.0/components/prism-erlang.min.js"></script>
  <script src="/js/prism-winn.js"></script>
</head>
<body class="bg-white text-gray-900 antialiased">
  <nav class="fixed top-0 w-full bg-white/80 backdrop-blur-md border-b border-gray-100 z-50">
    <div class="max-w-5xl mx-auto px-6 py-4 flex items-center justify-between">
      <a href="/" class="text-xl font-extrabold tracking-tight text-winn-800">winn</a>
      <div class="flex items-center gap-8">
        <a href="/#features" class="text-sm font-medium text-gray-600 hover:text-gray-900 transition">Features</a>
        <a href="/#code" class="text-sm font-medium text-gray-600 hover:text-gray-900 transition">Code</a>
        <a href="/#roadmap" class="text-sm font-medium text-gray-600 hover:text-gray-900 transition">Roadmap</a>
        <a href="https://github.com/gregwinn/winn-lang" class="text-sm font-medium text-gray-600 hover:text-gray-900 transition">GitHub</a>
        <a href="/docs/" class="text-sm font-medium text-white bg-winn-700 hover:bg-winn-800 px-4 py-2 rounded-lg transition">Docs</a>
      </div>
    </div>
  </nav>
  <div class="pt-24 pb-20 px-6">
    <div class="max-w-5xl mx-auto flex flex-col lg:flex-row gap-12">
      <aside class="lg:w-56 flex-shrink-0">
        <h2 class="text-xs font-bold uppercase tracking-wider text-gray-400 mb-4">Documentation</h2>
        <nav class="space-y-1">
          <a href="/docs/getting-started/" class="doc-nav-link block px-3 py-2 text-sm font-medium rounded-lg __NAV_getting-started__ transition">Getting Started</a>
          <a href="/docs/language/" class="doc-nav-link block px-3 py-2 text-sm font-medium rounded-lg __NAV_language__ transition">Language Guide</a>
          <a href="/docs/stdlib/" class="doc-nav-link block px-3 py-2 text-sm font-medium rounded-lg __NAV_stdlib__ transition">Standard Library</a>
          <a href="/docs/modules/" class="doc-nav-link block px-3 py-2 text-sm font-medium rounded-lg __NAV_modules__ transition">Modules</a>
          <a href="/docs/orm/" class="doc-nav-link block px-3 py-2 text-sm font-medium rounded-lg __NAV_orm__ transition">ORM</a>
          <a href="/docs/otp/" class="doc-nav-link block px-3 py-2 text-sm font-medium rounded-lg __NAV_otp__ transition">OTP</a>
          <a href="/docs/cli/" class="doc-nav-link block px-3 py-2 text-sm font-medium rounded-lg __NAV_cli__ transition">CLI Reference</a>
          <a href="/docs/roadmap/" class="doc-nav-link block px-3 py-2 text-sm font-medium rounded-lg __NAV_roadmap__ transition">Roadmap</a>
        </nav>
      </aside>
      <main class="flex-1 min-w-0">
        <div id="doc-content" class="prose"><p class="text-gray-400">Loading...</p></div>
      </main>
    </div>
  </div>
  <footer class="py-12 px-6 border-t border-gray-100">
    <div class="max-w-5xl mx-auto flex flex-col sm:flex-row items-center justify-between gap-4">
      <span class="text-sm text-gray-400">Winn v0.8.0 — Made by <a href="https://github.com/gregwinn" class="text-gray-600 hover:text-gray-900">Greg Winn</a></span>
      <div class="flex items-center gap-6">
        <a href="https://github.com/gregwinn/winn-lang" class="text-sm text-gray-400 hover:text-gray-900 transition">GitHub</a>
        <a href="/docs/" class="text-sm text-gray-400 hover:text-gray-900 transition">Docs</a>
        <a href="https://marketplace.visualstudio.com/items?itemName=gregwinn.language-winn-vscode" class="text-sm text-gray-400 hover:text-gray-900 transition">VS Code</a>
        <a href="https://github.com/gregwinn/winn-lang/releases" class="text-sm text-gray-400 hover:text-gray-900 transition">Releases</a>
      </div>
    </div>
  </footer>
  <script id="md-source" type="text/markdown">'

TEMPLATE_TAIL='</script>
  <script>
    const md = document.getElementById("md-source").textContent;
    document.getElementById("doc-content").innerHTML = marked.parse(md);
    // Map sh to bash for Prism, then highlight all code blocks
    document.querySelectorAll("pre code").forEach(function(block) {
      var cls = block.className || "";
      if (cls.indexOf("language-sh") !== -1) {
        block.className = cls.replace("language-sh", "language-bash");
      }
      // Ensure unlabeled blocks get basic highlighting
      if (!block.className || block.className.indexOf("language-") === -1) {
        block.classList.add("language-winn");
      }
      Prism.highlightElement(block);
    });
  </script>
</body>
</html>'

# Map of slug -> title
declare -A TITLES=(
  ["getting-started"]="Getting Started"
  ["language"]="Language Guide"
  ["stdlib"]="Standard Library"
  ["modules"]="Modules"
  ["orm"]="ORM"
  ["otp"]="OTP"
  ["cli"]="CLI Reference"
  ["roadmap"]="Roadmap"
)

SLUGS=("getting-started" "language" "stdlib" "modules" "orm" "otp" "cli" "roadmap")

for slug in "${SLUGS[@]}"; do
  md_file="$DOCS_DIR/$slug.md"
  if [ ! -f "$md_file" ]; then
    echo "Warning: $md_file not found, skipping"
    continue
  fi

  out_dir="$DOCS_DIR/$slug"
  mkdir -p "$out_dir"

  title="${TITLES[$slug]}"

  # Build the page — replace title and nav active state
  page="$TEMPLATE_HEAD"
  page="${page//__TITLE__/$title}"

  # Set active nav link
  for s in "${SLUGS[@]}"; do
    if [ "$s" = "$slug" ]; then
      page="${page//__NAV_${s}__/bg-winn-50 text-winn-700 font-semibold}"
    else
      page="${page//__NAV_${s}__/text-gray-700 hover:bg-winn-50 hover:text-winn-700}"
    fi
  done

  # Rewrite inter-doc links: (foo.md) -> (/docs/foo/)
  # Escape </script to prevent breaking out of script tag
  md_content=$(sed -e 's/(\([a-z-]*\)\.md)/(\/docs\/\1\/)/g' -e 's/<\/script/<\\\/script/g' "$md_file")

  echo "${page}${md_content}${TEMPLATE_TAIL}" > "$out_dir/index.html"
  echo "Built: $out_dir/index.html"
done

echo "Done! Built ${#SLUGS[@]} doc pages."
