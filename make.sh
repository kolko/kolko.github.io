#!/bin/bash

mkdir -p ./opencarbon_kolko
for page in ./data/blog/*; do
    page_name="$(echo ${page##*/} | awk '{print tolower($0)}')"
    cp -a "$page" ./opencarbon_kolko/${page_name}.txt
    echo '{{indexmenu_n>1000}}' > ./opencarbon_kolko/start.txt
done

mkdir -p ./githubio
echo "<html lang='ru-RU'>
<head>
<!-- Yandex.Metrika counter -->
<script type='text/javascript' >
   (function(m,e,t,r,i,k,a){m[i]=m[i]||function(){(m[i].a=m[i].a||[]).push(arguments)};
   m[i].l=1*new Date();k=e.createElement(t),a=e.getElementsByTagName(t)[0],k.async=1,k.src=r,a.parentNode.insertBefore(k,a)})
   (window, document, 'script', 'https://mc.yandex.ru/metrika/tag.js', 'ym');

   ym(53586970, 'init', {
        clickmap:true,
        trackLinks:true,
        accurateTrackBounce:true,
        webvisor:true
   });
</script>
<noscript><div><img src='https://mc.yandex.ru/watch/53586970' style='position:absolute; left:-9999px;' alt='' /></div></noscript>
<!-- /Yandex.Metrika counter -->

<!-- Global site tag (gtag.js) - Google Analytics -->
<script async src='https://www.googletagmanager.com/gtag/js?id=UA-139905506-1'></script>
<script>
  window.dataLayer = window.dataLayer || [];
  function gtag(){dataLayer.push(arguments);}
  gtag('js', new Date());

  gtag('config', 'UA-139905506-1');
</script>
<meta charset='utf-8'>

<title>MVP Блог об IT и около</title>
<Description>IT, программирование, управление, бизнес, психология, эффективность</Description>

<meta name='description' content='IT, программирование, управление, бизнес, психология, эффективность'>
<meta name='keywords' content='IT программирование управление бизнес психология эффективность'>

</head>
<body>
<p>Есть <a href='https://dev7.cloudfox.com/блоги_и_отзывы:krat_nikolay:start'>филиал</a></p>
<h1>Статьи:</h1>" > ./index.html
for page in $( ls ./data/blog/ | sort -r); do
    echo "<p><a href='/githubio/${page##*/}.html'>${page##*/}</a>" >> ./index.html

    echo "<html lang='ru-RU'><head>
    <!-- Yandex.Metrika counter -->
<script type='text/javascript' >
   (function(m,e,t,r,i,k,a){m[i]=m[i]||function(){(m[i].a=m[i].a||[]).push(arguments)};
   m[i].l=1*new Date();k=e.createElement(t),a=e.getElementsByTagName(t)[0],k.async=1,k.src=r,a.parentNode.insertBefore(k,a)})
   (window, document, 'script', 'https://mc.yandex.ru/metrika/tag.js', 'ym');

   ym(53586970, 'init', {
        clickmap:true,
        trackLinks:true,
        accurateTrackBounce:true,
        webvisor:true
   });
</script>
<noscript><div><img src='https://mc.yandex.ru/watch/53586970' style='position:absolute; left:-9999px;' alt='' /></div></noscript>
<!-- /Yandex.Metrika counter -->

<!-- Global site tag (gtag.js) - Google Analytics -->
<script async src='https://www.googletagmanager.com/gtag/js?id=UA-139905506-1'></script>
<script>
  window.dataLayer = window.dataLayer || [];
  function gtag(){dataLayer.push(arguments);}
  gtag('js', new Date());

  gtag('config', 'UA-139905506-1');
</script>
<title>MVP Блог. $(head -n 1 ./data/blog/${page} | tr '#' ' ')</title>

<meta name='description' content='$(head -n 6 ./data/blog/${page} | tail -n 5)'>
<meta name='keywords' content='IT программирование управление бизнес психология эффективность'>
    </head>" > ./githubio/${page##*/}.html

    if [[ "$page" == "2020-"* ]]; then
        echo '<body><a href="/">Назад</a><br><br><script src="/showdown-new.min.js?v=2"></script><textarea id="sourceTA" style="display: none">' >> ./githubio/${page##*/}.html
    else
        echo '<body><a href="/">Назад</a><br><br><script src="/showdown.min.js"></script><textarea id="sourceTA" style="display: none">' >> ./githubio/${page##*/}.html
    fi
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

#git add ./githubio
#git add ./opencarbon_kolko
