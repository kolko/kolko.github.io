# Проблема приемного папы. Процессная должостная инструкция для продуковнера зрелого крупного продукта.
Tags: компиляторы, грамматики

**Внимание! Это не статья, а мои заметки чтобы разобраться в теме статического анализа и грамматик. Я не уверен что сам смогу понять суть написанного через некоторое время, а вам даже пробовать не советую.**


#### Вопросы без ответа
- ПАРСЕР-КОМБИНАТОРЫ???
- ЧЕМ СЕЙЧАС ПАРСИТСЯ СИ, ПЛЮСЫ, ПИТОН, JAVA???
- Чем парсить bash? Чем пользуется shellcheck?

#### Ссылки изучить


https://pygments.org/docs/lexers/?highlight=bash

https://news.ycombinator.com/item?id=14550301

http://www.aosabook.org/en/bash.html

https://www.oilshell.org/blog/2019/02/07.html

https://github.com/nil0x42/shnake/blob/master/shnake/lexer.py

https://stackoverflow.com/questions/5491775/how-to-write-a-shell-lexer-by-hand


**qwe:**


3 основных типа синтаксических анализаторов: универсальный, нисходящий и восходящий.

Универсальные методы:
- алг Кока-Янгера-Касами (слишком неэффективный алг)
- алг Эрли (слишком неэффективный алг)


stmt (statement) - инструкция
expr (expression) - выражение
stmt -> if ( expr ) stmt else stmt


Восходящий синтаксический анализ связан с классом "правых порождений" - когда на каждом шаге переписывается крайний справа нетерминал.

Язык, который может быть сгенерирован грамматикой, называется контекстно-свободным языком.

В левых порождениях в каждом предложении выбирается крайний слева нетерминал, в правых - наоборот.


"(Регулярные языки)Конечный автомат не умеет считать".
"(КСГ)Грамматика может считать только две вещи, но не три (для трех вроде как нужны КЗГ)".

Требование объявления переменных перед использованием не может быть проверено КСГ.


Четких правил что должно относится к лексическому, а что к синтаксическому анализу, нет. Регулярные языки болше подходят для определения идентификаторов, констант, ключевых слов и пробельных символов. Грамматики более приспособлены для описания вложенных структур, таких как сбалансированные скорбки, пары begin end, if then else итд. Эти вложенные структуры не могут быть описаны регулярными выражениями.

Леворекурсивная грамматика, где существует A => Aa

Что нельзя в ксг: переменная объявлена до ее использования, wcw где w - это рандомная строка, проверить что количество параметров в объявлении функции равно переданным. Такое в языках часто делается на этапе семантического анализа.

Неоднозначности грамматики должен исправлять разработчик грамматики, в то время как факторизация, устранение левой рекурсии - можно делать алгоритмами автоматически.

Алгоритмы нисходящего разбора могут потребовать операции отката, когда один из вариантов продукции не подошел и потребовался другой. Один из алгоритмов - рекурсивный спуск. Предисктивный синтаксический анализ - это частный случай анализа методом рекурсивного спуска, но не требующий отката. Предиктивный анализ выбирает нужную продукцию путем просмотра X входных символов вперед. Класс грамматик, для которых можно построить предиктивный синтаксический анализатор, которому нужно подсмотреть K символов называют классом LL(k). Его распространенная версия LL(1) - когда нужно посмотреть только 1 доп.символ входной строки.


Предиктивные синтаксические анализаторы могут быть построены для LL(1).
LL(1) - первая L это сканирование входного потока слева направо, вторая L это получение левого порождения, а 1 - использование на каждом шаге предпросмотра на 1 символ.

В LL(1) не может быть ни левой рекурсии ни неоднозначности.

Грамматика A -> a|b не принадлежит LL(1) если нарушается правило: Если из b выводится э, то a не порождает ни одну строку, начинающуюся с терминала из FOLLOW(A). Аналогично для a. (чтобы не было неоднозначности "выбрать эту ветку нетерминала A или закончить нетерминал A").




Популярный алгоритм для LR грамматик - это перенос/свертка. Когда входящий поток w "сворачивается" в обратном направлении от листьев к корню грамматики E. Для этого в грамматике находятся "основы", которые совпадут с частью вх.потока и их можно будет свернуть в нетерминал. A -> ab - здесь ab - это основа.

К LR не относятся грамматики с конфликтом "перенос/свертка" (когда непонятно делать перенос или свертку) и "свертка/свертка" (когда есть два подходящих основания и непонятно какой выбрать).

LR(k) - первая L это сканирование входного потока слева направо, R это построение правого порождения в обратном порядке.


Есть разные варианты построения анализаторов, например простой (simple) LR - SLR. Более распространены: канонический LR и LALR.

Плюсы LR перед LL:
- LR можно построить практически для всех КСГ, а неподходящие КСГ в типичных случаях (для типичных конструкция в языках программирования) - можно исправить
- LR - это один из самых эффективных методов анализа без возврата
- LR может обнаруживать синтаксические ошибки как только это становится возможным
- класс LR грамматик - это надмножество грамматик, которые можно проанализировать предиктивным или LL методами
- объяснение: если для LL(k) мы должны выбрать продукцию по k входным символам, то в LR(k) мы это делаем по k входным символам плюс по правосентенциальной форме продукции (части которая уже свернута и лежит в "стеке" анализатора)
Главный минус - сложность построения LR-анализатора, но тут можно использовать автоматические анализаторы, например Yacc (генератор LALR-анализаторов).


Канонический LR - добавляет в таблицы терминал, который должен слудовать за продукцией FOLLOW(A), чтобы можно было ее применить. Количество терминалов для канонического LR(1) - равно одному и т.п. Но это приводит к разростанию состояний таблицы (например до нескольких тысяч в С, где при использовании LALR всего несколько сотен состояний).
LALR (lookahead LR) - склеивает состояния с одинаковыми ядрами, но разными терминалами. Из-за этого количество состояний в таблице сравнимо с SLR.



Неоднозначные грамматики не могут быть LR-грамматикой. Но с помощью правил ассоциативности и приоритетов (операторов) можно настроить генератор LR грамматики, чтобы он устранил неоднозначности. Например:
- с помощью указания приоритета, что * выше чем +, мы можем устранить неоднозначность грамматики: E -> E + E | E * E | ( E ) | id. При разборе id + id * id возникнет такая ситуация: в стеке будет E + E, а в входе * id - это конфликт переноса/свертки, мы можем свернуть E -> E + E или сделать перенос и свернуть E -> E * E. Нл если мы укажем, что приоритет * выше, то анализатор поймет в какой ситуации как поступать
- с помощью указания ассоциативности, например что + левоассоциативен, при разборе id + id + id, когда на стеке 'id + id', а на входе '+ id' - анализатор не знает делать перенос или свертку. Но зная, что + левоассоциативен может понять, что сначала нужно делать свертку.

Неоднозначных грамматик можно избежать, исправив неоднозначность. Но это добавит новые правила в грамматику, она станет менее лаконичной и увеличится кол-во состояний LR таблицы. С другой стороны, при использовании неоднозначности - нужно быть очень аккуратным, чтобы она работала корректно.


В Yacc правила по-умолчанию для разрешения неоднозначности: конфликт свертка/свертка разрешается в пользу конструкции, которая находится в спецификации раньше; конфликт перенос/свертка решается в пользу переноса (авто-фикс висящего else).







#### Лексический анализ.

Лексемы -> Токены.
Токен состоит из имени токена и значения атрибута (например, <number; ссылка на число>).
Для простоты термин токен можно считать терминалом в синтаксическом анализаторе.



#### Синтаксический анализ.

BNF (Backus-Naur Form) - контекстно-свободная грамматика.
Состоит из 4 компонентов:
1. Множество терминальных символов или токенов.
2. Множество нетерминалов.
3. Множество продукций (stmt -> if ( expr ) stmt else stmt )
4. Стартовый нетерминал (с которого начинается разбор).

Дерево разбора КСГ обладает свойствами:
1. Корень дерева помечен стартовым символом
2. Каждый лист помечен терминалом или e
3. Каждый внутренний узел - нетерминал


Левоассоциативные операторы ( +-/* )
list -> list + digit | digit
digit -> 1 | 2 | … | 9

Правоассоциативные ( = )
right -> letter = right | letter
letter -> a | b | … | z

2 приоритета операторов:
expr -> expr + term | expr - term | term
term -> term * factor | term / factor | factor
factor -> digit | ( expr )


Синтаксически управляемая трансляция - это когда к продукциям грамматики мы присоединяем код, который принимает аттрибуты (символы или результаты кода продукций нетерминалов) и возвращающая новый стнтезированный аттрибут (как в ply). Порядок выполнения кода управляется грамматикой. Например, так можно сделать транслятор инфиксной записи в постфиксную, транслятор кода в синтаксическое дерево или для вычисления выражения.

Предиктивный синтаксический анализатор - анализатор, который использует нисходящий подход (от корня к листьям), он читает по одному символу и для каждого символа имеет одну процедуру, ее обрабатывающую. Соответственно, для каждого нетерминала(имеется в виду, что на каждом шаге анализа) грамматика должна соответствовать условию, что множества FIRST(a) FIRST(b) FIRST(..), где a b - все возможные варианты нетерминала, а FIRST - множетсво их первых символов - не пересекаются. Проще говоря, не должно быть случаев когда новый символ можно трактовать по-разному. (что-то типа ДКА, наверное)

Левая рекурсия
Левую рекурсию пораждает подобные продукции:
expr -> expr + term
Это вызывает проблемы в анализаторах, работающих методом рекурсивного спуска - они зациклятся.

Левую рекурсию можно устранить, например:
A -> Aa | b
переделать в
A -> bR
R -> aR | e


Предиктивный анализатор не может обработать леворекурсивную грамматику.

Запись токена в таблицу символов (имя переменной) обычно делает синтаксический анализатор, лексический только возвращает лексему с токеном. Это происходит потому, что при работе с таблицей символов нужно учитывать блочную структуру языка (например, локальные перемееные в функции, которые переопределяют глобальную переменную модуля) - а ее понимает только синтаксический анализатор.


Основными используемыми промежуточными представлениями являются дерево разбора (например аст) и трехадресный код. Причем часто строится и то и другое: трехадресный код удобен для оптимизации, а дерево для проверки семантики.

Конкретный и абстрактный синтаксис.
Чтобы реализовать приоритеты операторов (например, сложения и умножения), в синтаксисе заводятся разные нетерминалы (term и factor), но часто в трехадресном коде или АСТ уже не нужно их различать и это будет переусложнением. Поэтому можно в правилах трансляции этих (конкретных) нетерминалов порождать абстрактные элементы. Например, сложение, вычитание, умножение и деление в языке java переводятся в узел Op(‘/‘, term1, factor2).
Вот таблица трансляции некоторых операций java (в порядке приоритета):
assign =
cond ||
cond &&
rel == !=
rel < <= >= >
op + -
op * / %
not !
minus -(unary)
access [ ]


Статические проверки
Некоторые проверки сложно или невозможно закодировать в грамматике и их выполняют отдельно. Например что операция break находится в конструкции switch или цикле, что декларация идентификатора в блоке выполнена только один раз, проверка типов и т. д.

Ода из проверок: проверка на L- и R-значения (r-value, l-value). L-значение располагается в левой стороне присваивания и должна быть ячейкой памяти (переменная, массив с индексом), а r-значние должен непосредственно иметь значние, которое можно присвоить.

￼
![Схема лексического анализатора](https://github.com/kolko/kolko.github.io/raw/master/data/static/2020-05-06_static_analysis/lexer_schema.jpg)


Лексический анализ редко бывает контекстно-независимым, часто в лексичейский анализатор передаются параметры состояния статического анализатора. Например, в с++ при использовании шаблонов раньше нужно было между >> ставить пробел, т.к. лексер был контекстно-независимый и парсил это как сдвиг: A<B<X> >  (контекстно-зависимая лексика).

А еще есть подход scaner-less. (TODO?) Парсер-комбинаторы.


Восходящий лексический анализ (вроде как устаревшая техника). LR(k) (L - слева направо, k - колическтво читаемых символов), обычно юзается если k=1, иначе большие накладные расходы.

LALR(1) могут анализировать Yacc и Bison и только их.






Синтаксически управляемая трансляция - это трансляция, управляемая контекстно-свободной грамматикой. (грубо говоря, когда к каждому правилу КСГ мы прикручиваем код, например строим АСТ, генерируем промежуточный код или интерпретируем его).
Синтаксически управляемое определение - это КСГ с атрибутами и правилами. Атрибуты - это когда мы во время разбора добавляем инфу к нетерминалам (например тип). Правила - это код, выполняемый в продукциях.
Атрибуты бывают синтезированные и наследуемые.
СУО только с синтезируемыми атрибутами называют S-атрибутными определениями, такое СУО может быть удобно реализовано совместно с LR-анализатором, как например в Yacc.
СУО называется L-атрибутной, когда оно использует наследуемые атрибуты, но для вычисления наследуемого атрибута используются только синтезируемые атрибуты сестер, располагающиеся слева от вычисляемого нетерминала и наследуемые атрибуты родителя. Например: A -> B C, здесь B.i может зависеть только от A.s и не может от C.s(т.к. C еще не вычислен, расположен справа). Напротив, для вычисления C.i могут использоваться A.s и B.s. inh имеет смысл назначать еще не вычисленным нетерминалам (чтобы они при разборе им воспользовались), synt предназначены для возврата.
СУО без побочных эффектов называют атрибутной грамматикой. В них правила определяют значения атрибутов через значения других атрибутов и не делают ничего другого.

L-атрибутное СУО можно реализовать только в LL-анализаторе (точнее, в нисходящем анализаторе), т.е. работает только при нисходящем обходе. Использование наследуемых атрибутов в LR-анализаторе (хаками) в конце концов приведет к стратегии «составь все дерево разбора целиком и потом обойди его», т.е. универсальным алгоритмом.

Не все схемы управляемой трансляции можно реализовать во время LL или LR анализа. Чтобы была возможность реализовать все, то нужно сначала построить дерево разбора игнорируя действия, потом действия «навесить» на это дерево и выполнить обход дерева в прямом порядке.



??? Как разрабатывать грамматики, когда невозможно выделить в лексере ключевые слова. (Вроде как можно управлять лексером из синтаксического анализатора).




#### Понятное объяснение когда язык перестает быть регулярным (оригинальная статья https://habr.com/ru/post/491538/)
￼
![Картинка из статьи 1](https://github.com/kolko/kolko.github.io/raw/master/data/static/2020-05-06_static_analysis/habr_1.jpg)

Осталось добавить, что грамматика называется контекстно-свободной (КС-грамматикой), если все левые части правил вывода — единичные нетерминалы.

![Картинка из статьи 2](https://github.com/kolko/kolko.github.io/raw/master/data/static/2020-05-06_static_analysis/habr_2.jpg)
￼
В статье еще есть хороший пример грамматики общего вида. «У получившегося алгоритма есть интересная особенность: правила со сложной левой частью позволяют как бы «перемещать» группы символов; в данном случае нетерминалы перемещаются в правую часть строки. Похожий паттерн часто встречается в алгоритмах для машин Тьюринга.»

![Картинка из статьи 3](https://github.com/kolko/kolko.github.io/raw/master/data/static/2020-05-06_static_analysis/habr_3.jpg)