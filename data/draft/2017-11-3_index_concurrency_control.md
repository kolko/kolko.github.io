# Лекция CMU Database Systems - 18 Index Concurrency Control (Fall 2017).
Tags: читательский дневник, databases, алгоритмы, конспекты

> Дисклеймер: это вольный конспект видео-лекции своими словами, картинки честно украдены со слайдов, надеюсь я ни чего не нарушаю :) Лекция легко понимается даже с хреновым знанием английского, так что если у вас есть в запасе лишний час - лучше посмотрите ее.

Посмотрел интересную лецию на [youtube](https://www.youtube.com/watch?v=poRiberfVxE). В ней вводятся понятия блокировок, с помощью которых можно реализовывать конкурентный доступ к СУБД, с минимальным вредом для производительности.

В качестве примера приводится проблема фантомных записей: ты в одной транзакции сначала прочитал одну версию данных, а потом другую, которую заинсертила и закоммитила другая транзакция. Стандартная ситуация при read commited или repetable reads. Но как от нее защититься и почему repetable reads защищает от всего, кроме этого, в противовес serializable? В чем сложность?

![iso_levels](https://kolko.github.io/data/static/2017-11-3_index_concurrency_control.md/isolation_levels.png)
Уровни изоляции

![iso2_levels](https://kolko.github.io/data/static/2017-11-3_index_concurrency_control.md/isolation_levels_implementation.png)
Реализация уровней изоляции

Двух-фазная блокировка

https://en.wikipedia.org/wiki/Two-phase_locking
https://edu.vsu.ru/mod/book/view.php?id=12519&chapterid=223
