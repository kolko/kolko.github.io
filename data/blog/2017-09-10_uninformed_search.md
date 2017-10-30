# Заметки по неинформированному поиску.
Tags: читательский дневник, алгоритмы

[википедия](https://ru.wikipedia.org/wiki/Неинформированный_метод_поиска)

Читал толстенную книгу [Искусственный интеллект. Современный подход](https://www.goodreads.com/book/show/9649159) и, в который раз читая про типовые алгоритмы поиска, решил записать какие полезные мысли они вызывают в моей голове.

С поиском в ширину и в глубину все знакомы. Первый ест память, разворачивая у себя в голове все дерево, которое он обходит. Второй может может долго и глубоко искать решение, которое может быть совсем рядом с вершиной графа, а то и вовсе зациклиться.

В коде приложений часто встречаются рекурсивный код, напоминающий поиск в глубину по своей структуре. Либо прямо, когда объекты ссылаются на себе подобных, образуя граф, либо косвенно, ссылающихся на другие объекты, которые имеют обратные ссылки. В результате могут образовываться невычислимые циклы разной сложности. Часто возможно заранее определить примерную глубину рекурсии и важно всегда вводить лимит глубины рекурсии, чему нас учит «поиск с ограничением глубины» Вероятно, стоит сразу вводить это ограничение, когда становится известно, что в алгоритме возможны циклы, в противном случае приложение может даже не выводить ошибок, а просто зависать намертво.

Сложив вместе устойчивость к циклам, поиск узлов в порядке углубления в граф поиска в ширину и потребление памяти поиска в глубину, можно получить «поиск в глубину с итеративным углублением». Он работает, перезапуская «поиск с ограничением глубины», увеличивая, каждый раз, глубину поиска. Так как он не хранит уже обсчитанные узлы, выглядит он очень расточительным. Поинт в том, что если граф поиска расширяется пропорционально высоте, то сложность этого алгоритма не сильно отличается от поиска в ширину, сохраняя при этом экономичность по памяти. Взять, например, поиск по файловой системе. Если хочется искать, проходя от уровня к уровню, но писать структуры для хранения такого большого состояния поиска в ширину и код его обхода не хочется - можно перезапускать поиск в глубину с лимитом каждого уровня: код получится простой, поиск полным, а памяти будет затрачено мало. Я не предлагаю использовать данный метод для поиска в ФС, для этого наверняка есть специальные алгоритмы и многое зависит от факторов: если потребуется поиск по содержимому файлов, каждое действие станет слишком дорогим, чтобы повторять его на каждой итерации. Но если речь идет только о именах файлов, а таблица файлов ФС помещается в кеш оперативной памяти - вероятно, в пропорции скорость/простота/качество это будет хорошим вариантом.

Оставшиеся поиски по критерию стоимости и двунаправленный поиск достаточно специфичны, чтобы как-то обобщить их на повседневную работу с кодом. Хотя аналогом двунаправленного поиска (с ручным управлением) можно считать операцию join, знакомую всем по реляционным БД. Одинарные join могут быть тривиальными, но для решения множественных join нескольких таблиц, движок реляционной БД может, на основании своих знаний о «графе» (приблизительные размеры таблиц, условия фильтрации, объем оперативной памяти), выбрать места склеивания таблиц и порядок склеивания, чтобы результирующий подграф поиска был минимальным. И хоть такие сложные вещи, как executor запросов в БД, редко приходится писать, бывает полезно искать пути поиска решения с разных сторон. Например, при расчете начисления абон.платы пользователям, заранее загрузить в кеш все тарифы и вычислить их сумму, если это возможно, а не делать это каждый раз. Это же касается замены кучи запросов к БД при генерации страницы в каком-нибудь веб фреймворке одним большим запросом. Не делайте кучи подзапросов…