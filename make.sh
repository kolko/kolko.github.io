#!/bin/bash

mkdir -p ./opencarbon_kolko
for page in ./data/blog/*; do
    page_name="$(echo ${page##*/} | awk '{print tolower($0)}')"
    cp -a "$page" ./opencarbon_kolko/${page_name}.txt
    echo '{{indexmenu_n>1000}}' > ./opencarbon_kolko/start.txt
done

mkdir -p ./githubio
echo "<html><body>
<p>Есть <a href='http://opencarbon.ru/блоги_и_отзывы:krat_nikolay:start'>филиал</a></p>
<h1>Статьи:</h1>" > ./index.html
for page in $( ls ./data/blog/ | sort -r); do
    echo "<p><a href='/githubio/${page##*/}.html'>${page##*/}</a>" >> ./index.html

    echo '<html><body><script src="/showdown.min.js"></script><textarea id="sourceTA" style="display: none">' > ./githubio/${page##*/}.html
    cat ./data/blog/${page} >> ./githubio/${page##*/}.html
    echo "</textarea><div id='targetDiv'></div>
    <script>
  var text = document.getElementById('sourceTA').value,
      target = document.getElementById('targetDiv'),
      converter = new showdown.Converter(),
      html = converter.makeHtml(text);

    target.innerHTML = html;
</script>
</body>
</html>" >> ./githubio/${page##*/}.html
done

git add ./githubio
git add ./opencarbon_kolko
