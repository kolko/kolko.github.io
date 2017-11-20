#!/bin/bash

mkdir -p ./opencarbon_kolko
for page in ./data/blog/*; do
    cp -a "$page" ./opencarbon_kolko/${page##*/}.txt
    echo '{{indexmenu_n>1000}}' > ./opencarbon_kolko/start.txt
done

mkdir -p ./githubio
echo "<html><body>
<p>Есть <a href='http://opencarbon.ru/участники:kolko:start'>филиал</a></p>
<h1>Статьи:</h1>" > ./index.html
for page in ./data/blog/*; do
    echo "<p><a href='https://kolko.github.io/githubio/${page##*/}.html'>${page##*/}</a>" >> ./index.html

    echo '<html><body><script src="/showdown.min.js"></script><textarea id="sourceTA" style="display: none">' > ./githubio/${page##*/}.html
    cat $page >> ./githubio/${page##*/}.html
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
