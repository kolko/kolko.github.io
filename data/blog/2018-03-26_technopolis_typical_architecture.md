# Лекции Технополиса. Проектирование высоконагруженных систем (осень 2017).
Tags: читательский дневник, высоконагруженные системы, конспект, спойлеры

[Статья на хабре](https://habrahabr.ru/company/odnoklassniki/blog/347798/)

[Лекция #2. HIGHLOAD. Типовые архитектуры | Технострим](https://www.youtube.com/watch?v=m9S37qxbvN8)

Докладчик проходится по следующим темам построения архитектуры бэкенда:
- развитие от толстых клиентов (приложение) в тонкие (web) и обратно в толстые (web)
- ресурсы серверов, способы оптимизации одного ресурса за счет другого
- переход от вертикального масштабирования серверов к горизонтальному, как распределить бэкенд при горизонтальном масштабировании
- работа с централизованной БД и переход к распределенным БД
- ACID, CAP, проблемы кешей
- очереди
- микросервисная архитектура

Перечислены плюсы, минусы и стоимость перехода на более сложную архитектуру, описаны типовые проблемы обеспечения консистентности и их решения.

Доклад хорошо воспринимается на скорости х1,5


Далее вольный конспект.

***

#### Сравнение архитектур

|			|Толстый клиент |Тонкий клиент(web)	|Толстый клиент(web)
|----|----|----|----|
|Трафик			| + 		| -			| +
|Задержки		| + 		| -			|
|Кэширование		| + 		| -			| +
|Постоянное соединение	| + 		| -			| +
|Пуши			| + 		| -			| +
|Работа в оффлайн	| + 		| -			| +
|Сервер без состояния	| + 		| -			| -
|Обновление		| - 		| +			| +
|Совместимость API	| - 		| +			| +
|Консистентность состояния| - 		| +			| +
|Локализация		| - 		| +			| +
|Эксперименты		| - 		| +			| +
|Скорость разработки	|		| +			| +


###### Проблемы производительности (при росте продукта):
 - Пропускная способность. Увеличивается объемы трафика, нужно чтобы сеть и оборудование могло с объемом справляться
 - Ошибки. Пользователь не должен получать ошибки, при горизонтальном масштабировании нужно уметь повторять запросы и уметь определять в каком месте произошла ошибка (что трудно, когда много серверов, либо когда один запрос обрабатывает несколько сервисов)
 - Время обслуживания. В 99.9 процентиле, запрос пользователя должен обрабатываться менее, чем за 300мс. При внедрении микросервисов нужно учитывать повышение латентности обработки запроса, по сравнению с монолитом


Нужно уметь считать потребление основных ресурсов сервера: память, процессор, диск, сеть и понимать, что один ресурс можно менять на другой.

Нужно понимать сколько пользователей вашего сервиса поместится в память (актуально для демонов с БД в памяти), за счет применения других структур данных можно сократить потребление памяти за счет потребления процессора. Память работает не так быстро, как процессор, за счет больших вычислений и меньшего обращения к памяти - можно повысить утилизацию процессора.

У процессора можно определить процент полезной работы вашего кода от системного времени ОС(system) и времени ожидания IO (iowait). Возможно, стоит ускорить работу за счет тюнинга/настройки ОС, либо определить что алгоритм не оптимально обращается к системе (слишком много ждет).

Так как гигагерцы уже так сильно не растут, следует уделять внимание многопоточному программированию.

Стоит учитывать возможные объемы дискового пространства сервера, латентность доступа к диску и количество операций/байт с диском.

У сети тоже нужно знать латентность и объем доступной полосы пропускания, в ДЦ она на порядок ниже, чем доступ к диску. Также не стоит забывать о возможном лимите на количество сетевых пакетов, т.к. это нагружает сетевой стек.


###### Оптимизации утилизации ресурсов. Можно обменивать в разные стороны:
 - процессор/память. С помощью более вычислительно-емких структур данных сократить объем данных в памяти (например, применить сжатие). С помощью избыточных данных в памяти производить меньше расчетов на CPU (например, расширить структуру данных предрасчитанными полями или кешем).
 - память/диск. Кэшировать данные с диска в памяти. Переносить редко-используемые данные на диск.
 - процессор/объем. Пропускная способность/задержка. Обрабатывать запросы/данные пачками (векторные операции в cpu, запись нескольких запросов на диск одним большим блоком, группировка запросов, перед отправкой в сеть) - увеличит пропускную способность системы, но повысит время ожидания обработки одного запроса.
Часто за счет этих оптимизаций происходит неверное трактование результатов бенчмарков. Например, БД отдает данные быстрее, чем может их читать с диска (или записать), либо пакетная обработка запросов работает быстрее, чем способен выдержать сетевой стек при одном запросе на пакет. Нужно учитывать эти допущения при исследовании.


###### Разделение бэкенда:
 - Веб сервер <-> сервер логики. Позволит делать разные "фронтенды" к логике (веб-сервер, API-сервер, клиент для мобилок), проще тестировать, поможет в архитектурном разделении кода.
 - Шардирование по веб-серверам. Средняя сложность. Требуется маршрутизирование до веб-сервера. Если на веб-сервере есть состояние, то клиента нужно закреплять за веб-сервером, либо выносить состояние на внешний сервис.
 - Функциональный сервис. Малая сложность. Если БД будет внешняя, то можно реализовать собственную функцию шардирования на веб-сервере и больше проблем не будет.
 - БД. Максимальная сложность. Проблема единой точки отказа, лага в репликации, отсутствия атомарности при обновлении нескольких БД.


###### Проблема отказов. Если сервер, при выполнении запроса клиента возвращает ошибку, что показывать клиенту?
 - Сдаваться, нельзя повторять (at most once) - отобразить ошибку клиенту, пусть он сам решит что с ней делать
 - Сдаваться нельзя, повторять (at least once) - повторять запрос, пока он не выполнится
Проблема в том, что при отказе непонятно, выполнился запрос (например, была ли запись в БД) или нет. Возможно, что дублирующий запрос продублирует данные.
Для этого нужно реализовать идемпотентные операции (повтор которых не приводит к порче или дублировании информации).
Например, перед отправкой запроса на добавление нового сообщения в чат, получить от сервера ID нового сообщения. В этом случае, при повторной отправке, по ID сообщения, БД сможет понять есть ли у нее уже это сообщение.


###### Оптимизации работы с СУБД:
 - построить индексы по всем использующимся запросам
 - использовать только короткие транзакции (не выполнять долгие операции в коде, между началом и окончанием транзакции, например сетевой запрос)
 - денормализировать данные для более быстрого доступа к ним
 - минимализировать логику, хранящуюся в СУБД
 - минимум Foreign Key (???)


###### Проблемы распределенных БД:
 - Мастер-слейв. При синхронной репликации, отказ слейва приводит к неработоспособности мастера, либо к неконсистентности слейва. При асинхронной репликации данные на слейве будут запаздывать. Возможна проблема, когда после запроса на запись к мастеру идет запрос на чтение к слейву и данные не находятся, лечится отправкой близжайших запросов на чтение к мастеру, а лаг других клиентов, выполняющих чтение считается допустимым.
 - Мастер-мастер. Проблема конфликтов. Лечится кворумом (большинство право), либо работой с разрешением конфликтов: автоматически last win в Cassandra, либо вручную: Vector Clock в Voldemort/Riak, с помощью оптимистичной блокировки (CAS, compare and swap), paxos, структурами данных без конфликтов (Conflict-free replicated data type CRDT, умеет не все).


###### Проблемы кэширования:
 - холодный старт. При рестарте кеша с потерей состояния БД может не справиться с количеством запросов. Решение: система кэширования должна сохранять состояние на диск.
 - отказы при обновлении кеша. В БД информацию обновили, а при обновлении кеша произошла ошибка. Решается отдельным процессом обновления значений в кеше: сохранение timestamp изменений в БД и вычитывании свежих изменений фоновым процессом и применение его в кеш, либо посылка лога репликации на сервер кеша и его применение к кешу. Допускается лаг обновления данных в кеше, зато данные в конечном счете придут.


###### Очереди.
 - низкое время обработки запросов
 - масштабируемость обработчиков
 - эластичность. Скачки количества запросов не приведут к отказам, просто увеличится время их выполнения
 - отказоустойчивость
 - последовательность обработки. Для исключения проблем конкуренции, можно использовать очередь для последовательной обработки запросов

Фишки:
 - cпособ хранения: память, диск, распределенные
 - гарантии доставки
 - queue/Topic. Можно читать по событию из очереди, а можно подписываться на события
 - отложенная доставка
 - протухание. Иногда необработанные события теряют свою актуальность
 - пакетная обработка. Сбор пачки событий для более производительной обработки

Проблемы:
 - не избавляет нас от проблем атомарности в распределенных системах: если агент обработки очереди сделал запись в БД и БД отпала - непонятно обработалась ли запись в очереди. Все аналогично с проблемой отказов
 - требуется мониторить очередь, отследить ее переполнение и ситуации, когда обработка очереди не поспевает за новыми запросами (есть хорошая лекция по поводу проблем очередей)


###### Микросервисы
Фишки:
 - масштабирование
 - простота разработки: быстрая компиляция и запуск, меньше связанность, проще тестирование, гибкий цикл релизов
 - простота развертывания
 - изоляция отказов

Минусы:
 - производительность
 - сложность разработки: удаленные вызовы, discovery, сложная отладка
 - сложность развертывания
 - больше точек отказа

Боль:
 - конфигурация
 - сбор логов
 - сбор статистики
 - мониторинг



###### Выводы:
 - отказы всегда есть и будут, нужно учитывать их при проектировании архитектуры. Другими словами, если нет необходимости дробить сервисы - не дробите, не привнесете туда проблем
 - физические ограничения нужно знать и понимать. При завышенных показателях бенчмарков - нужно понимать за счет чего это достигается
 - CAP теорема - не бывает идеальных распределенных БД
 - при усложнении архитектуры бэкенда и технологий, проблемы не уходят, а трансформируются в другие, более сложные. Но при росте проекта это необходимо
